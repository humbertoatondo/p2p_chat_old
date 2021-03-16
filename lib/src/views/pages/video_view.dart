import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:p2p_chat/src/business_logic/blocs/web_rtc_bloc/web_rtc_bloc.dart';
import 'package:p2p_chat/src/views/utils/buttons.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class VideoView extends StatefulWidget {
  VideoView({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _VideoViewState createState() => _VideoViewState();
}

class _VideoViewState extends State<VideoView> {
  final channel = new WebSocketChannel.connect(
      Uri.parse("ws://192.168.1.89:3000/connection"));

  final webRtcBloc = WebRtcBloc(VideoConnectionInitial());

  @override
  void initState() {
    super.initState();
    channel.stream.listen((message) {
      var data = json.decode(message);

      if (webRtcBloc.state is VideoConnectionInitial) {
        webRtcBloc.add(ReceiveOffer(data["offer"]));
      } else if (webRtcBloc.state is VideoConnectionWaitingForAnswer) {
        webRtcBloc.add(ReceiveAnswer(data["answer"]));
      } else if (webRtcBloc.state is VideoConnectionWaitingForIceCandidates) {
        webRtcBloc.add(ReceiveIceCandidates(data["candidates"]));
      } else if (webRtcBloc.state is VideoConnectionWaitingForStatus) {
        webRtcBloc.add(ReceiveConnectionStatus(data["status"]));
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    webRtcBloc.close();
    channel.sink.close();
  }

  Flexible videoRenderer(state) => Flexible(
        child: Container(
          child: RTCVideoView(
            state.peersData.localRenderer,
            mirror: true,
          ),
          key: Key('local'),
          margin: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
          decoration: BoxDecoration(color: Colors.black),
        ),
      );

  SizedBox videoRenderers() => SizedBox(
        height: 400,
        child: Row(
          children: [
            Flexible(
              child: Container(
                child: RTCVideoView(
                  webRtcBloc.localRenderer,
                  mirror: true,
                ),
                key: Key('local'),
                margin: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
                decoration: BoxDecoration(color: Colors.black),
              ),
            ),
            Flexible(
              child: Container(
                child: RTCVideoView(
                  webRtcBloc.remoteRenderer,
                  mirror: true,
                ),
                key: Key('remote'),
                margin: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
                decoration: BoxDecoration(color: Colors.black),
              ),
            )
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              BlocBuilder(
                  cubit: webRtcBloc,
                  builder: (BuildContext context, VideoConnectionState state) {
                    if (state is VideoConnectionWaitingForAnswer) {
                      channel.sink
                          .add(json.encode({"offer": webRtcBloc.offer}));
                      return Container();
                    } else if (state
                        is VideoConnectionWaitingForIceCandidates) {
                      channel.sink
                          .add(json.encode({"answer": webRtcBloc.answer}));
                      return Container();
                    } else if (state is VideoConnectionWaitingForStatus) {
                      channel.sink.add(
                          json.encode({"candidates": webRtcBloc.candidates}));
                      return Container();
                    } else if (state is VideoConnectionEstablished) {
                      channel.sink.add(json.encode({"status": 1}));
                      return videoRenderers();
                    }
                    return Container();
                  }),
              Expanded(
                child: Container(),
              ),
              SizedBox(
                height: 70,
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    ExpandedButton(
                      buttonText: "Request Connection",
                      backgroundColor: Colors.amber,
                      onPressed: () {
                        if (webRtcBloc.state is VideoConnectionInitial) {
                          webRtcBloc.add(SendOffer());
                        }
                      },
                    ),
                    ExpandedButton(
                      buttonText: "Close socket",
                      backgroundColor: Colors.amber,
                      onPressed: () {
                        channel.sink.close();
                      },
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
