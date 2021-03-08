part of 'web_rtc_bloc.dart';

abstract class WebRtcEvent extends Equatable {
  const WebRtcEvent([Object list]);

  @override
  List<Object> get props => [];
}

class InitPeerConnection extends WebRtcEvent {
  InitPeerConnection() : super([]);
}
