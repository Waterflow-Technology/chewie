import 'dart:developer';
import 'dart:math' as math;

import 'package:chewie/src/chewie_player.dart';
import 'package:chewie/src/helpers/adaptive_controls.dart';
import 'package:chewie/src/notifiers/index.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class PlayerWithControls extends StatefulWidget {
  const PlayerWithControls({
    Key? key,
    this.position = 0.0,
    this.showVideoID = false,
    this.userId = "",
  }) : super(key: key);
  final double position;
  final bool showVideoID;
  final String userId;

  @override
  State<PlayerWithControls> createState() => _PlayerWithControlsState();
}

class _PlayerWithControlsState extends State<PlayerWithControls>
    with WidgetsBindingObserver {
  late double position;
  late bool showVideoID;
  late bool startLoop;
  randomVideoID() async {
    do {
      setState(() {
        showVideoID = false;
      });
      await Future.delayed(
        const Duration(seconds: 6),
      );
      setState(() {
        position = math.Random().nextDouble() * 70;
        showVideoID = true;
      });
      await Future.delayed(
        const Duration(seconds: 5),
      );
    } while (startLoop);
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    position = 0;
    showVideoID = true;
    startLoop = true;
    log("hello Chewie");
    randomVideoID();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ChewieController chewieController = ChewieController.of(context);

    double calculateAspectRatio(BuildContext context) {
      final size = MediaQuery.of(context).size;
      final width = size.width;
      final height = size.height;

      return width > height ? width / height : height / width;
    }

    Widget buildControls(
      BuildContext context,
      ChewieController chewieController,
    ) {
      return chewieController.showControls
          ? chewieController.customControls ?? const AdaptiveControls()
          : const SizedBox();
    }

    Widget buildPlayerWithControls(
      ChewieController chewieController,
      BuildContext context,
    ) {
      return Stack(
        children: <Widget>[
          if (chewieController.placeholder != null)
            chewieController.placeholder!,
          InteractiveViewer(
            transformationController: chewieController.transformationController,
            maxScale: chewieController.maxScale,
            panEnabled: chewieController.zoomAndPan,
            scaleEnabled: chewieController.zoomAndPan,
            child: Center(
              child: AspectRatio(
                aspectRatio: chewieController.aspectRatio ??
                    chewieController.videoPlayerController.value.aspectRatio,
                child: VideoPlayer(chewieController.videoPlayerController),
              ),
            ),
          ),
          if (chewieController.overlay != null &&
              !chewieController.isFullScreen)
            Padding(
              padding: EdgeInsets.only(
                left: chewieController.videoPlayerController.value.position
                                .inSeconds %
                            10 ==
                        0
                    ? 150
                    : 0,
                top: chewieController.videoPlayerController.value.position
                                .inSeconds %
                            10 ==
                        0
                    ? 150
                    : 0,
              ),
              child: chewieController.overlay!,
            ),
          if (Theme.of(context).platform != TargetPlatform.iOS)
            Consumer<PlayerNotifier>(
              builder: (
                BuildContext context,
                PlayerNotifier notifier,
                Widget? widget,
              ) =>
                  Visibility(
                visible: !notifier.hideStuff,
                child: AnimatedOpacity(
                  opacity: notifier.hideStuff ? 0.0 : 0.8,
                  duration: const Duration(
                    milliseconds: 250,
                  ),
                  child: const DecoratedBox(
                    decoration: BoxDecoration(color: Colors.black54),
                    child: SizedBox.expand(),
                  ),
                ),
              ),
            ),
          if (!chewieController.isFullScreen)
            buildControls(context, chewieController)
          else
            Stack(
              children: [
                SafeArea(
                  bottom: false,
                  child: buildControls(context, chewieController),
                ),
                Visibility(
                  visible: showVideoID,
                  child: Positioned(
                    top: position,
                    right: position,
                    child: Text(
                      "VID${widget.userId}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        shadows: [
                          Shadow(color: Colors.black),
                          Shadow(color: Colors.green),
                          Shadow(color: Colors.red),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            )
        ],
      );
    }

    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      return Center(
        child: SizedBox(
          height: constraints.maxHeight,
          width: constraints.maxWidth,
          child: AspectRatio(
            aspectRatio: calculateAspectRatio(context),
            child: buildPlayerWithControls(chewieController, context),
          ),
        ),
      );
    });
  }
}
