part of 'web_rtc_bloc.dart';

abstract class WebRtcEvent extends Equatable {
  const WebRtcEvent([Object list]);

  @override
  List<Object> get props => [];
}

class SendOffer extends WebRtcEvent {
  bool isOffer;
  dynamic remoteOffer;
  SendOffer(this.isOffer, this.remoteOffer) : super([isOffer, remoteOffer]);
}

class ReceiveOffer extends WebRtcEvent {
  String remoteOffer;
  List<dynamic> remoteCandidates;
  bool isOffer;
  ReceiveOffer(this.remoteOffer, this.remoteCandidates, this.isOffer)
      : super([remoteOffer, remoteCandidates, isOffer]);
}
