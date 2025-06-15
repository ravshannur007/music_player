import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:lottie/lottie.dart';
import 'package:marquee/marquee.dart';
import 'package:music_player/constants/app_colors.dart';
import 'package:music_player/controller/audio_controller.dart';
import 'package:music_player/widgets/my_button.dart';

class BottomPlayer extends StatelessWidget {
  const BottomPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final audioController = AudioController();
    return ValueListenableBuilder(
      valueListenable: audioController.currentIndex,
      builder: (context, currentIndex, _) {
        final currentSong = audioController.currentSong;
        if (currentSong == null) return SizedBox.shrink();
        return GestureDetector(
          onTap: () {
            // Navigator.push(context, MaterialPageRoute(builder: (context) => PlayerScreen),);
          },
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(100),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(21),
                topRight: Radius.circular(21),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.blurColor,
                  offset: Offset(8, 8),
                  blurRadius: 15,
                  spreadRadius: 1,
                ),
                BoxShadow(
                  color: AppColors.blurColor,
                  offset: Offset(-8, -8),
                  blurRadius: 15,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: SizedBox(
                    height: 20,
                    child: Marquee(
                      text: currentSong.title.toString().split('/').last,
                      blankSpace: 50,
                      startPadding: 30,
                      velocity: 10,
                    ),
                  ),
                ),
                StreamBuilder(
                  stream: audioController.audioPlayer.positionStream,
                  builder: (context, snapshot) {
                    final position = snapshot.data ?? Duration.zero;
                    final duration =
                        audioController.audioPlayer.duration ?? Duration.zero;
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: ProgressBar(
                        progress: position,
                        total: duration,
                        progressBarColor: Color(0xFF4A5668),
                        baseBarColor: Colors.black26,
                        bufferedBarColor: Colors.black12,
                        thumbColor: Color(0xFF4A5668),
                        barHeight: 3,
                        thumbRadius: 6,
                        timeLabelLocation: TimeLabelLocation.none,
                        onSeek: (duration) {
                          audioController.audioPlayer.seek(duration);
                        },
                      ),
                    );
                  },
                ),
                Row(
                  children: [
                    SizedBox(
                      child: Lottie.asset(
                        'lib/assets/animations/music.json',
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(child: SizedBox()),
                    Row(
                      children: [
                        MyButton(
                          blurFirstColor: Colors.white54,
                          blurSecondColor: Colors.white54,
                          btnBackGround: Colors.blueAccent.shade200,
                          child: Icon(Icons.skip_previous_rounded),
                          onPress: audioController.previousSong,
                        ),
                        SizedBox(width: 16),
                        StreamBuilder(
                          stream: audioController.audioPlayer.playerStateStream,
                          builder: (context, snapshot) {
                            final playerState = snapshot.data;
                            final processingState =
                                playerState?.processingState;
                            final playing = playerState?.playing;
                            if (processingState == ProcessingState.loading ||
                                processingState == ProcessingState.buffering) {
                              return Container(
                                margin: EdgeInsets.all(8.0),
                                height: 32,
                                width: 32,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.primary,
                                  ),
                                ),
                              );
                            }
                            ;
                            return MyButton(
                              onPress: audioController.togglePlayPause,
                              child: Icon(
                                playing == true
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded,
                                color: playing == true
                                    ? AppColors.primary
                                    : Colors.black,
                              ),
                            );
                          },
                        ),
                        SizedBox(width: 16),
                        MyButton(
                          blurFirstColor: Colors.white54,
                          blurSecondColor: Colors.white54,
                          btnBackGround: Colors.blueAccent.shade200,
                          onPress: audioController.nextSong,
                          child: Icon(Icons.skip_next_rounded),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
