import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:p2p_chat/src/business_logic/blocs/web_rtc_bloc/web_rtc_bloc.dart';
import 'package:p2p_chat/src/views/utils/buttons.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final webRtcBloc = WebRtcBloc(WebRtcInitial());

  @override
  void dispose() {
    super.dispose();
    webRtcBloc.close();
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
        height: 350,
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
                child: RTCVideoView(webRtcBloc.remoteRenderer),
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
                  builder: (BuildContext context, WebRtcState state) {
                    if (state is WebRtcLoaded) {
                      return videoRenderer(state);
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
                      buttonText: "Init Peer Connection",
                      backgroundColor: Colors.amber,
                      onPressed: () {
                        if (webRtcBloc.state is WebRtcInitial) {
                          webRtcBloc.add(InitPeerConnection());
                        }
                      },
                    ),
                    ExpandedButton(
                      buttonText: "Second",
                      backgroundColor: Colors.amber,
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
