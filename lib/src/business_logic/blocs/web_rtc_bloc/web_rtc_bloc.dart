import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:p2p_chat/src/business_logic/models/peers_data.dart';

part 'web_rtc_event.dart';
part 'web_rtc_state.dart';

class WebRtcBloc extends Bloc<WebRtcEvent, WebRtcState> {
  var localRenderer = new RTCVideoRenderer();
  var remoteRenderer = new RTCVideoRenderer();

  WebRtcBloc(WebRtcState initialState) : super(initialState);

  @override
  Stream<WebRtcState> mapEventToState(
    WebRtcEvent event,
  ) async* {
    if (event is InitPeerConnection) {
      yield WebRtcLoading();
      localRenderer.initialize();
      remoteRenderer.initialize();
      final peerConnection = await _createPeerConnection();
      final peersData = new PeersData(
        peerConnection: peerConnection,
        localRenderer: localRenderer,
        remoteRenderer: remoteRenderer,
      );
      yield WebRtcLoaded(peersData);
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
      remoteRenderer.srcObject = stream;
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
}
