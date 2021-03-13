part of 'web_rtc_bloc.dart';

abstract class WebRtcEvent extends Equatable {
  const WebRtcEvent([Object list]);

  @override
  List<Object> get props => [];
}

class SendOffer extends WebRtcEvent {
  SendOffer() : super();
}

class ReceiveOffer extends WebRtcEvent {
  final String remoteOffer;
  ReceiveOffer(this.remoteOffer) : super([remoteOffer]);
}

class ReceiveAnswer extends WebRtcEvent {
  final String remoteAnswer;
  ReceiveAnswer(this.remoteAnswer) : super([remoteAnswer]);
}

class ReceiveIceCandidates extends WebRtcEvent {
  final List<dynamic> iceCandidates;
  ReceiveIceCandidates(this.iceCandidates) : super([iceCandidates]);
}

class ReceiveConnectionStatus extends WebRtcEvent {
  final int isSuccess;
  ReceiveConnectionStatus(this.isSuccess) : super([isSuccess]);
}
