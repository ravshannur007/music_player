import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import 'package:music_player/constants/app_colors.dart';
import 'package:music_player/controller/audio_controller.dart';

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
                Padding(padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4,),
                  child: SizedBox(
                    height: 20,
                    child: Marquee(text: currentSong.title),
                  ),
                ),
              ],
            ),
          ),
        );
      },

    );
  }
}
