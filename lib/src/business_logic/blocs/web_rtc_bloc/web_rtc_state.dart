part of 'web_rtc_bloc.dart';

abstract class VideoConnectionState extends Equatable {
  const VideoConnectionState([Object list]);

  @override
  List<Object> get props => [];
}

class VideoConnectionInitial extends VideoConnectionState {}

class VideoConnectionOfferSent extends VideoConnectionState {
  // final RTCPeerConnection peerConnection;
  final PeersData peersData;

  VideoConnectionOfferSent(this.peersData) : super([peersData]);
}

class VideoConnectionEstablished extends VideoConnectionState {
  final PeersData peersData;

  VideoConnectionEstablished(this.peersData) : super([peersData]);
}
