import 'package:flutter/material.dart';
import 'package:music_player/constants/app_colors.dart';
import 'package:music_player/controller/audio_controller.dart';
import 'package:music_player/model/local_song_model.dart';
import 'package:music_player/utils/custom_text_styles.dart';
import 'package:music_player/widgets/my_button.dart';
import 'package:music_player/widgets/my_container.dart';

class SongListItem extends StatefulWidget {
  final LocalSongModel song;
  final int index;

  const SongListItem({super.key, required this.song, required this.index});

  @override
  State<SongListItem> createState() => _SongListItemState();
}

class _SongListItemState extends State<SongListItem> {
  String _formatDuration(int milliseconds) {
    int minutes = (milliseconds / 60000).floor();
    int second = ((milliseconds % 60000) / 1000).floor();
    return '$minutes:${second.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final audioController = AudioController();
    return ValueListenableBuilder(
      valueListenable: audioController.currentIndex,
      builder: (context, currentIndex, child) {
        return ValueListenableBuilder(
          valueListenable: audioController.isPlaying,
          builder: (context, isPlaying, child) {
            final isCurrentSong = currentIndex == widget.index;
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
              child: MyContainer(
                child: ListTile(
                  contentPadding: EdgeInsets.all(12),
                  leading: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[800],
                    ),
                    child: Icon(Icons.music_note, color: Colors.white54),
                  ),
                  title: Text(
                    widget.song.title,
                    style: myTextStyle15(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    widget.song.artist,
                    style: myTextStyle12(fontColor: Colors.black26),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatDuration(widget.song.duration),
                        style: myTextStyle12(fontColor: Colors.black26),
                      ),
                      SizedBox(width: 8),
                      MyButton(
                        onPress: (){},
                        child: Icon(
                          isCurrentSong && isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: isCurrentSong && isPlaying
                              ? AppColors.primary
                              : Colors.white54,
                          size: 27,
                        ),
                      ),
                    ],
                  ),
                  onTap: (){
                    audioController.playSong(widget.index);
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}
