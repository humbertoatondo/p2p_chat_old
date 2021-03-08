import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class PeersData extends Equatable {
  final RTCPeerConnection peerConnection;
  final RTCVideoRenderer localRenderer;
  final RTCVideoRenderer remoteRenderer;

  PeersData({
    @required this.peerConnection,
    @required this.localRenderer,
    @required this.remoteRenderer,
  });

  @override
  List<Object> get props => [
        peerConnection,
        localRenderer,
        remoteRenderer,
      ];
}
