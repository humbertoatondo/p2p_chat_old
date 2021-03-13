import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:p2p_chat/src/business_logic/blocs/web_rtc_bloc/web_rtc_bloc.dart';
import 'package:p2p_chat/src/views/utils/buttons.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:ansicolor/ansicolor.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final channel =
      new WebSocketChannel.connect(Uri.parse("ws://localhost:3000/connection"));

  final webRtcBloc = WebRtcBloc(VideoConnectionInitial());

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    channel.stream.listen((message) {
      var answer = json.decode(message);

      if (webRtcBloc.state is VideoConnectionOfferSent) {
        webRtcBloc
            .add(ReceiveOffer(answer["sdpOffer"], answer["candidate"], true));
      } else if (webRtcBloc.state is VideoConnectionInitial) {
        webRtcBloc.add(SendOffer(false, answer));
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
              videoRenderers(),
              BlocBuilder(
                  cubit: webRtcBloc,
                  builder: (BuildContext context, VideoConnectionState state) {
                    if (state is VideoConnectionOfferSent) {
                      final offer = {
                        "isOffer": true,
                        "sdpOffer": state.peersData.sdpOffer,
                        "candidate": state.peersData.candidate,
                      };
                      channel.sink.add(json.encode(offer));
                      // return videoRenderers(state);
                      // return videoRenderers(state);
                      return Container();
                    } else if (state is VideoConnectionEstablished) {
                      // print("\n\n\n\n\nESTABLISHED\n\n\n\n\n");

                      if (!state.peersData.isOffer) {
                        final offer = {
                          "isOffer": false,
                          "sdpOffer": state.peersData.sdpOffer,
                          "candidate": state.peersData.candidate,
                        };
                        channel.sink.add(json.encode(offer));
                      }

                      return Container();
                      // return videoRenderers(state);
                    } else {
                      return Container();
                    }
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
                          webRtcBloc.add(SendOffer(true, null));
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
