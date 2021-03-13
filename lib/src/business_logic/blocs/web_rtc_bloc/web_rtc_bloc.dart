import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:logger/logger.dart';
import 'package:sdp_transform/sdp_transform.dart';

part 'web_rtc_event.dart';
part 'web_rtc_state.dart';

class WebRtcBloc extends Bloc<WebRtcEvent, VideoConnectionState> {
  RTCPeerConnection peerConnection;
  var localRenderer = new RTCVideoRenderer();
  var remoteRenderer = new RTCVideoRenderer();
  List<String> candidates = [];
  String offer;
  String answer;

  WebRtcBloc(VideoConnectionState initialState) : super(initialState);

  @override
  Stream<VideoConnectionState> mapEventToState(WebRtcEvent event) async* {
    if (event is SendOffer) {
      localRenderer.initialize();
      remoteRenderer.initialize();
      peerConnection = await _createPeerConnection();
      offer = await _createOffer();
      yield VideoConnectionWaitingForAnswer();
    } else if (event is ReceiveOffer) {
      localRenderer.initialize();
      remoteRenderer.initialize();
      peerConnection = await _createPeerConnection();
      await _setRemoteDescription(event.remoteOffer, true);
      answer = await _createAnswer();
      yield VideoConnectionWaitingForIceCandidates();
    } else if (event is ReceiveAnswer) {
      await _setRemoteDescription(event.remoteAnswer, false);
      yield VideoConnectionWaitingForStatus();
    } else if (event is ReceiveIceCandidates) {
      event.iceCandidates.forEach((candidate) async {
        await _setCandidate(candidate);
      });
      yield VideoConnectionEstablished();
    } else if (event is ReceiveConnectionStatus) {
      yield VideoConnectionEstablished();
    }
  }

  Future<RTCPeerConnection> _createPeerConnection() async {
    Map<String, dynamic> configuration = {
      "iceServers": [
        {"url": "stun:stun.l.google.com:19302"},
      ]
    };

    final Map<String, dynamic> offerSdpConstraints = {
      "mandatory": {
        "OfferToReceiveAudio": true,
        "OfferToReceiveVideo": true,
      },
      "optional": [],
    };

    RTCPeerConnection pc =
        await createPeerConnection(configuration, offerSdpConstraints);

    MediaStream localStream = await _getUserMedia();
    localRenderer.srcObject = localStream;
    await pc.addStream(localStream);

    // Get and print Ice Candidates when generating sdp offer.
    pc.onIceCandidate = (e) {
      if (e.candidate != null) {
        var cand = {
          'candidate': e.candidate.toString(),
          'sdpMid': e.sdpMid.toString(),
          'sdpMlineIndex': e.sdpMlineIndex,
        };

        candidates.add(json.encode(cand));
      }
    };

    pc.onIceConnectionState = (e) {};

    // Receive remote stream (video) from peer.
    pc.onAddStream = (stream) {
      remoteRenderer.srcObject = stream;
    };

    pc.onConnectionState = (s) {};

    return pc;
  }

  Future<MediaStream> _getUserMedia() async {
    final Map<String, dynamic> mediaConstraints = {
      "audio": false,
      "video": {
        "facingMode": "user",
      },
    };

    MediaStream localStream =
        await navigator.mediaDevices.getUserMedia(mediaConstraints);

    return localStream;
  }

  Future<String> _createOffer() async {
    RTCSessionDescription description =
        await peerConnection.createOffer({'offerToReceiveVideo': 1});

    peerConnection.setLocalDescription(description);

    var session = parse(description.sdp);
    return json.encode(session);
  }

  Future<String> _createAnswer() async {
    RTCSessionDescription description =
        await peerConnection.createAnswer({'offerToReceiveVideo': 1});

    peerConnection.setLocalDescription(description);

    var session = parse(description.sdp);
    return json.encode(session);
  }

  Future<void> _setRemoteDescription(
      String remoteDescription, bool isOffer) async {
    dynamic session = await jsonDecode(remoteDescription);

    String sdp = write(session, null);

    RTCSessionDescription description =
        new RTCSessionDescription(sdp, isOffer ? 'offer' : 'answer');

    await peerConnection.setRemoteDescription(description);
  }

  Future<void> _setCandidate(String remoteCandidate) async {
    dynamic session = await jsonDecode('$remoteCandidate');

    dynamic candidate = new RTCIceCandidate(
        session['candidate'], session['sdpMid'], session['sdpMlineIndex']);

    await peerConnection.addCandidate(candidate);
  }
}
