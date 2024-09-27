import 'package:floating/floating.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pip_video/video_player_page.dart';
import 'package:video_player/video_player.dart';

class PIPExampleApp extends StatefulWidget {
  const PIPExampleApp({super.key});

  @override
  State<PIPExampleApp> createState() => _PIPExampleAppState();
}

class _PIPExampleAppState extends State<PIPExampleApp>
    with WidgetsBindingObserver {
  final String videoUrl =
      'https://firebasestorage.googleapis.com/v0/b/winter-spotify.appspot.com/o/Videos%2F%5B%23%E1%84%8E%E1%85%AC%E1%84%8B%E1%85%A2%E1%84%8C%E1%85%B5%E1%86%A8%E1%84%8F%E1%85%A2%E1%86%B7%5D%20aespa%20WINTER%20(%E1%84%8B%E1%85%A6%E1%84%89%E1%85%B3%E1%84%91%E1%85%A1%20%E1%84%8B%E1%85%B1%E1%86%AB%E1%84%90%E1%85%A5)%20-%20Armageddon%20%20%E1%84%89%E1%85%AD!%20%E1%84%8B%E1%85%B3%E1%86%B7%E1%84%8B%E1%85%A1%E1%86%A8%E1%84%8C%E1%85%AE%E1%86%BC%E1%84%89%E1%85%B5%E1%86%B7%20%20MBC240601%E1%84%87%E1%85%A1%E1%86%BC%E1%84%89%E1%85%A9%E1%86%BC.mp4?alt=media&token=0aa6e1f9-07ac-4b82-996e-573d5ed088bb';
  late Floating pip;
  bool isPipAvailable = false;
  late VideoPlayerController _controller;

  @override
  void initState() {
    pip = Floating();
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPiPAvailability();

    _controller = VideoPlayerController.networkUrl(
      Uri.parse(videoUrl),
    )..initialize().then((_) {
        // Set the video to loop and start playing once initialized
        _controller.setLooping(true);
        _controller.play();
        _controller.setVolume(1);
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  _checkPiPAvailability() async {
    isPipAvailable = await pip.isPipAvailable;
    setState(() {});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print('App lifecycle state: $state');
    if (isPipAvailable) {
      if (state == AppLifecycleState.inactive) {
        pip.enable(const ImmediatePiP(aspectRatio: Rational.landscape()));
      } else if (state == AppLifecycleState.resumed) {
        pip.cancelOnLeavePiP();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PiPSwitcher(
      floating: pip,
      childWhenDisabled: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            VideoPlayerWidget(
              controller: _controller,
            ),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  if (isPipAvailable) {
                    pip.enable(
                        const ImmediatePiP(aspectRatio: Rational.landscape()));
                  }
                },
                child:
                    Text(isPipAvailable ? 'Enable PIP' : 'PIP not available'),
              ),
            ),
          ],
        ),
      ),
      childWhenEnabled: VideoPlayerWidget(
        controller: _controller,
      ),
    );
  }
}
