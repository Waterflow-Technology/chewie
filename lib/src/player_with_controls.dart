import 'package:chewie/src/chewie_player.dart';
import 'package:chewie/src/helpers/adaptive_controls.dart';
import 'package:chewie/src/notifiers/index.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class PlayerWithControls extends StatefulWidget {
  const PlayerWithControls({Key? key}) : super(key: key);

  @override
  State<PlayerWithControls> createState() => _PlayerWithControlsState();
}

class _PlayerWithControlsState extends State<PlayerWithControls> {
  late double left;
  late double top;
  late double bottom;
  late double right;
  late bool startLoop;
  randomVideoID() async {
    do {
      setState(() {
        left = 0;
        top = 100;
        bottom = 0;
        right = 0;
      });
      await Future.delayed(
        const Duration(seconds: 5),
      );
      setState(() {
        left = 150;
        top = 0;
        bottom = 0;
        right = 0;
      });
      await Future.delayed(
        const Duration(seconds: 5),
      );
      setState(() {
        left = 0;
        top = 0;
        bottom = 100;
        right = 0;
      });
      await Future.delayed(
        const Duration(seconds: 5),
      );
      setState(() {
        left = 0;
        top = 0;
        bottom = 0;
        right = 150;
      });
      await Future.delayed(
        const Duration(seconds: 5),
      );
    } while (startLoop);
  }

  @override
  void initState() {
    left = 0;
    top = 0;
    startLoop = true;
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
          if (chewieController.overlay != null)
            Padding(
              padding: EdgeInsets.only(
                left: left,
                top: top,
                bottom: bottom,
                right: right,
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
            SafeArea(
              bottom: false,
              child: buildControls(context, chewieController),
            ),
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
