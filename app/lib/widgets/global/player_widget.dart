import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:melotune/services/providers/home_provider.dart';
import 'package:melotune/services/providers/player_provider.dart';
import 'package:melotune/utils/colors.dart';
import 'package:melotune/widgets/global/scrolling_text.dart';
import 'package:provider/provider.dart';

class PlayerWidget extends StatefulWidget {
  const PlayerWidget({super.key});

  @override
  State<PlayerWidget> createState() => _PlayerWidgetState();
}

class _PlayerWidgetState extends State<PlayerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation _animation;

  @override
  void initState() {
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _animation =
        Tween<double>(begin: 100, end: 0).animate(_animationController);
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final PlayerProvider playerProvider = Provider.of<PlayerProvider>(context);
    if (playerProvider.playerStatus == PlayerStatus.playing) {
      _animationController.forward();
    } else if (playerProvider.currentPlaying == null ||
        (!playerProvider.isPlayingFromPlaylist &&
            playerProvider.playerStatus == PlayerStatus.loading)) {
      _animationController.reverse();
    }
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) => Transform.translate(
        offset: Offset(0, _animation.value),
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Container(
                  padding: const EdgeInsets.only(
                      left: 10, bottom: 20, right: 10, top: 8),
                  width: double.infinity,
                  height: 80,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      border:
                          Border.all(color: Colors.indigo.shade100, width: 3)),
                  child: playerProvider.currentPlaying == null ||
                          !playerProvider.player.currentPosition.hasValue
                      ? const SizedBox()
                      : StreamBuilder<Duration>(
                          stream: playerProvider.player.currentPosition,
                          builder: (context, snapshot) {
                            if (!snapshot.hasData ||
                                snapshot.data == null ||
                                !playerProvider.player.current.hasValue ||
                                playerProvider.player.current.value == null) {
                              return const SizedBox();
                            }
                            final Duration current = snapshot.data!;
                            final Duration total = playerProvider
                                .player.current.value!.audio.duration;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                    width: 200,
                                    height: 20,
                                    child: ScrollingText(
                                      text:
                                          playerProvider.currentPlaying!.title,
                                      textStyle: const TextStyle(fontSize: 15),
                                    )),
                                const SizedBox(height: 5),
                                Expanded(
                                  child: ProgressBar(
                                    thumbRadius: 8,
                                    thumbGlowRadius: 18,
                                    timeLabelTextStyle: const TextStyle(
                                        fontSize: 15, color: Colors.black87),
                                    thumbColor: Colors.indigo.shade100,
                                    progressBarColor: KColors.appPrimary,
                                    timeLabelPadding: 3.0,
                                    progress: current,
                                    total: total,
                                    onSeek: (duration) {
                                      playerProvider.player.seek(duration);
                                    },
                                  ),
                                ),
                              ],
                            );
                          },
                        )),
            ),
            Positioned(
              top: 4,
              right: 18,
              child: Row(
                children: [
                  if (Provider.of<HomeProvider>(context).searchContent == null)
                    _playerActionButton(
                        icon: Icons.shuffle,
                        isSmall: true,
                        color: playerProvider.isShuffle
                            ? Colors.blueGrey.shade400
                            : null,
                        onTap: () => playerProvider.setShuffle()),
                  const SizedBox(width: 10),
                  _playerActionButton(
                      icon: playerProvider.playerStatus == PlayerStatus.playing
                          ? Icons.pause
                          : Icons.play_arrow,
                      isSmall: true,
                      onTap: () => playerProvider.player.playOrPause()),
                  const SizedBox(width: 10),
                  _playerActionButton(
                    icon: Icons.close,
                    onTap: () => playerProvider.playerStopButton(),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _playerActionButton({
    required Function() onTap,
    required IconData icon,
    Color? color,
    bool isSmall = false,
  }) {
    return SizedBox(
      height: isSmall ? 34 : 40,
      width: isSmall ? 34 : 40,
      child: IconButton(
        onPressed: () => onTap(),
        icon: Icon(
          icon,
          size: isSmall ? 16 : 22,
          color: color != null ? Colors.white : Colors.blueGrey,
        ),
        style: IconButton.styleFrom(
            backgroundColor: color ?? Colors.indigo.shade100),
      ),
    );
  }
}
