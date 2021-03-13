import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class PeersData extends Equatable {
  final bool isOffer;
  final RTCPeerConnection peerConnection;
  final RTCVideoRenderer localRenderer;
  final RTCVideoRenderer remoteRenderer;
  final String sdpOffer;
  final List<dynamic> candidate;

  PeersData({
    @required this.isOffer,
    @required this.peerConnection,
    @required this.localRenderer,
    @required this.remoteRenderer,
    @required this.sdpOffer,
    @required this.candidate,
  });

  @override
  List<Object> get props => [
        isOffer,
        peerConnection,
        localRenderer,
        remoteRenderer,
        sdpOffer,
        candidate,
      ];
}
