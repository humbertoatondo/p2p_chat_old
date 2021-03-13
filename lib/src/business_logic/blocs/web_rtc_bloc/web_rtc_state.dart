part of 'web_rtc_bloc.dart';

abstract class VideoConnectionState extends Equatable {
  const VideoConnectionState([Object list]);

  @override
  List<Object> get props => [];
}

class VideoConnectionInitial extends VideoConnectionState {}

class VideoConnectionWaitingForAnswer extends VideoConnectionState {
  VideoConnectionWaitingForAnswer() : super();
}

class VideoConnectionWaitingForIceCandidates extends VideoConnectionState {
  VideoConnectionWaitingForIceCandidates() : super();
}

class VideoConnectionWaitingForStatus extends VideoConnectionState {
  VideoConnectionWaitingForStatus() : super();
}

class VideoConnectionEstablished extends VideoConnectionState {
  VideoConnectionEstablished() : super() {
    var logger = Logger(
      printer: PrettyPrinter(
          methodCount: 0, // number of method calls to be displayed
          errorMethodCount:
              8, // number of method calls if stacktrace is provided
          lineLength: 90, // width of the output
          colors: true, // Colorful log messages
          printEmojis: true, // Print an emoji for each log message
          printTime: true // Should each log print contain a timestamp
          ),
    );
    logger.i("Successfull video connection!");
  }
}
