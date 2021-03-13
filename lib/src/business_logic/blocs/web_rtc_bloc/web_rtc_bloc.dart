import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:p2p_chat/src/business_logic/models/peers_data.dart';
import 'package:sdp_transform/sdp_transform.dart';
// import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
// import 'package:web_socket_channel/status.dart' as status;
import 'package:ansicolor/ansicolor.dart';

part 'web_rtc_event.dart';
part 'web_rtc_state.dart';

class WebRtcBloc extends Bloc<WebRtcEvent, VideoConnectionState> {
  var _isOffer = false;
  RTCPeerConnection _peerConnection;
  var localRenderer = new RTCVideoRenderer();
  var remoteRenderer = new RTCVideoRenderer();
  String _sdpOffer;
  List<String> _candidates = [];
  PeersData _peersData;

  WebRtcBloc(VideoConnectionState initialState) : super(initialState);

  @override
  Stream<VideoConnectionState> mapEventToState(WebRtcEvent event) async* {
    if (event is SendOffer) {
      // Check if is sending or answering.
      localRenderer.initialize();
      remoteRenderer.initialize();
      _peerConnection = await _createPeerConnection();
      if (event.isOffer) {
        _sdpOffer = await _createOffer();
      } else {
        await _setRemoteDescription(
            event.remoteOffer["sdpOffer"], event.isOffer);
        _sdpOffer = await _createAnswer();
      }

      await new Future.delayed(const Duration(seconds: 3));

      _peersData = new PeersData(
        isOffer: event.isOffer,
        peerConnection: _peerConnection,
        localRenderer: localRenderer,
        remoteRenderer: remoteRenderer,
        sdpOffer: _sdpOffer,
        candidate: _candidates,
      );

      if (!event.isOffer) {
        yield VideoConnectionEstablished(_peersData);
      } else {
        yield VideoConnectionOfferSent(_peersData);
      }
    } else if (event is ReceiveOffer) {
      AnsiPen pen = new AnsiPen()..red();
      // print(pen(event.remoteOffer));
      await _setRemoteDescription(event.remoteOffer, event.isOffer);
      for (var candidate in event.remoteCandidates) {
        await _setCandidate(candidate);
      }

      yield VideoConnectionEstablished(_peersData);
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

        _candidates.add(json.encode(cand));

        AnsiPen yellow = new AnsiPen()..yellow();

        print(yellow(json.encode({
          'candidate': e.candidate.toString(),
          'sdpMid': e.sdpMid.toString(),
          'sdpMlineIndex': e.sdpMlineIndex,
        })));
      }
    };

    pc.onIceConnectionState = (e) {
      print(e);
    };

    // Receive remote stream (video) from peer.
    pc.onAddStream = (stream) {
      print('addStream: ' + stream.id);
      remoteRenderer.srcObject = stream;
    };

    AnsiPen pen = new AnsiPen()..magenta();
    pc.onConnectionState = (s) {
      print(pen(s));
    };

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
        await _peerConnection.createOffer({'offerToReceiveVideo': 1});

    _peerConnection.setLocalDescription(description);
    _isOffer = true;

    var session = parse(description.sdp);
    return json.encode(session);
  }

  Future<String> _createAnswer() async {
    RTCSessionDescription description =
        await _peerConnection.createAnswer({'offerToReceiveVideo': 1});

    _peerConnection.setLocalDescription(description);

    var session = parse(description.sdp);
    return json.encode(session);
  }

  Future<void> _setRemoteDescription(
      String remoteDescription, bool isOffer) async {
    dynamic session = await jsonDecode(remoteDescription);

    String sdp = write(session, null);

    RTCSessionDescription description =
        new RTCSessionDescription(sdp, isOffer ? 'answer' : 'offer');

    // print(description.toMap());

    await _peerConnection.setRemoteDescription(description);
  }

  Future<void> _setCandidate(String remoteCandidate) async {
    dynamic session = await jsonDecode('$remoteCandidate');
    // print(session);

    dynamic candidate = new RTCIceCandidate(
        session['candidate'], session['sdpMid'], session['sdpMlineIndex']);

    await _peerConnection.addCandidate(candidate);
  }
}
