import 'package:flutter/cupertino.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_player/model/local_song_model.dart';
import 'package:on_audio_query/on_audio_query.dart';

class AudioController {
  static final AudioController instance = AudioController._instance();

  factory AudioController() => instance;

  AudioController._instance() {
    _setupAudioPlayer();
  }

  final AudioPlayer audioPlayer = AudioPlayer();
  final OnAudioQuery audioQuery = OnAudioQuery();
  final ValueNotifier<List<LocalSongModel>> songs =
      ValueNotifier<List<LocalSongModel>>([]);
  final ValueNotifier<int> currentIndex = ValueNotifier<int>(-1);
  final ValueNotifier<bool> isPlaying = ValueNotifier<bool>(false);

  LocalSongModel? get currentSong => currentIndex.value < songs.value.length
      ? songs.value[currentIndex.value]
      : null;

  void _setupAudioPlayer() {
    audioPlayer.playerStateStream.listen((playerState) {
      isPlaying.value = playerState.playing;

      if (playerState.processingState == ProcessingState.completed) {
        if (currentIndex.value < songs.value.length - 1) {
          playSong(currentIndex.value + 1);
        } else {
          currentIndex.value = -1;
          isPlaying.value = false;
        }
      }
    });

    audioPlayer.positionStream.listen((_) {
      isPlaying.notifyListeners();
    });
  }

  Future<void> loadSongs() async {
    final fetchSongs = await audioQuery.querySongs(
      sortType: null,
      orderType: OrderType.ASC_OR_SMALLER,
      uriType: UriType.EXTERNAL,
      ignoreCase: true,
    );

    songs.value = fetchSongs
        .map(
          (songs) => LocalSongModel(
            id: songs.id,
            title: songs.title,
            artist: songs.artist ?? "Unknown Artist",
            uri: songs.uri ?? "",
            albumArt: songs.album ?? "",
            duration: songs.duration ?? 0,
          ),
        )
        .toList();
  }

  Future<void> playSong(int index) async {
    if (index < 0 || index >= songs.value.length) return;
    try {
      if (currentIndex.value == index && isPlaying.value) {
        await pauseSong();
        return;
      }
      currentIndex.value = index;
      final song = songs.value[index];
      await audioPlayer.stop();
      await audioPlayer.setAudioSource(AudioSource.uri(Uri.parse(song.uri),),
          preload: true,
      );
      await audioPlayer.play();
      isPlaying.value = true;
    } catch (e) {
      print("Error playing song: $e");
    }
  }

  Future<void> pauseSong()async{
    await audioPlayer.pause();
    isPlaying.value = false;
  }

  Future<void> resumeSongs() async {
    await audioPlayer.play();
    isPlaying.value = false;
  }

  void togglePlayPause() async{
    if(currentIndex.value == -1) return;
    try{
      if(isPlaying.value){
        await pauseSong();
      }else{
        await resumeSongs();
      }
    }catch(e){
      print("Error toggling play/pause: $e");
    }
  }

  Future<void> nextSong() async{
    if(currentIndex.value < songs.value.length -1){
      await playSong(currentIndex.value + 1);
    }
  }

  Future<void> previousSong() async{
    if(currentIndex.value > 0){
      await playSong(currentIndex.value - 1);
    }
  }

  void dispose(){
    audioPlayer.dispose();
  }
}
