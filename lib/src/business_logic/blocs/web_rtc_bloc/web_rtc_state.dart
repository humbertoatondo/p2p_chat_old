part of 'web_rtc_bloc.dart';

abstract class WebRtcState extends Equatable {
  const WebRtcState([Object list]);

  @override
  List<Object> get props => [];
}

class WebRtcInitial extends WebRtcState {}

class WebRtcLoading extends WebRtcState {}

class WebRtcLoaded extends WebRtcState {
  // final RTCPeerConnection peerConnection;
  final PeersData peersData;

  WebRtcLoaded(this.peersData) : super([peersData]);
}
