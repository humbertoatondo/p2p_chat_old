import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:p2p_chat/src/business_logic/models/peers_data.dart';
import 'package:sdp_transform/sdp_transform.dart';

part 'web_rtc_event.dart';
part 'web_rtc_state.dart';

class WebRtcBloc extends Bloc<WebRtcEvent, WebRtcState> {
  var _isOffer = false;
  RTCPeerConnection _peerConnection;
  var _localRenderer = new RTCVideoRenderer();
  var _remoteRenderer = new RTCVideoRenderer();

  WebRtcBloc(WebRtcState initialState) : super(initialState);

  @override
  Stream<WebRtcState> mapEventToState(
    WebRtcEvent event,
  ) async* {
    if (event is InitPeerConnection) {
      yield WebRtcLoading();
      _localRenderer.initialize();
      _remoteRenderer.initialize();
      _peerConnection = await _createPeerConnection();

      final peersData = new PeersData(
        isOffer: _isOffer,
        peerConnection: _peerConnection,
        localRenderer: _localRenderer,
        remoteRenderer: _remoteRenderer,
      );
      yield WebRtcLoaded(peersData);
      _createOffer();
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
    _localRenderer.srcObject = localStream;
    pc.addStream(localStream);

    // Get and print Ice Candidates when generating sdp offer.
    pc.onIceCandidate = (e) {
      if (e.candidate != null) {
        print(json.encode({
          'candidate': e.candidate.toString(),
          'sdpMid': e.sdpMid.toString(),
          'sdpMlineIndex': e.sdpMlineIndex,
        }));
      }
    };

    pc.onIceConnectionState = (e) {
      print(e);
    };

    // Receive remote stream (video) from peer.
    pc.onAddStream = (stream) {
      print('addStream: ' + stream.id);
      _remoteRenderer.srcObject = stream;
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

  void _createOffer() async {
    RTCSessionDescription description =
        await _peerConnection.createOffer({'offerToReceiveVideo': 1});

    var session = parse(description.sdp);
    print(session);
    print("HELLO FRIENDSSS\n\n\n\n\n");
    print(session);
    // print(json.encode(session));
    _isOffer = true;

    _peerConnection.setLocalDescription(description);
  }
}
