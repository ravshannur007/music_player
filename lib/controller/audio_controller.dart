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

  // TO'G'IRLANGAN currentSong getter
  LocalSongModel? get currentSong {
    // Xavfsizlik tekshiruvi qo'shildi
    if (currentIndex.value < 0 ||
        currentIndex.value >= songs.value.length ||
        songs.value.isEmpty) {
      return null;
    }
    return songs.value[currentIndex.value];
  }

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
    try {
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
    } catch (e) {
      print("Error loading songs: $e");
      songs.value = []; // Bo'sh ro'yxat o'rnatish xato bo'lsa
    }
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
      await audioPlayer.setAudioSource(
        AudioSource.uri(Uri.parse(song.uri)),
        preload: true,
      );
      await audioPlayer.play();
      isPlaying.value = true;
    } catch (e) {
      print("Error playing song: $e");
    }
  }

  Future<void> pauseSong() async {
    await audioPlayer.pause();
    isPlaying.value = false;
  }

  // TO'G'IRLANGAN resumeSongs metodi
  Future<void> resumeSongs() async {
    await audioPlayer.play();
    isPlaying.value = true; // Bu yerda true bo'lishi kerak edi
  }

  void togglePlayPause() async {
    if (currentIndex.value == -1) return;
    try {
      if (isPlaying.value) {
        await pauseSong();
      } else {
        await resumeSongs();
      }
    } catch (e) {
      print("Error toggling play/pause: $e");
    }
  }

  Future<void> nextSong() async {
    if (currentIndex.value < songs.value.length - 1) {
      await playSong(currentIndex.value + 1);
    }
  }

  Future<void> previousSong() async {
    if (currentIndex.value > 0) {
      await playSong(currentIndex.value - 1);
    }
  }

  // QO'SHIMCHA FOYDALI METODLAR

  // Pozitsiya bilan bog'liq metodlar
  Stream<Duration> get positionStream => audioPlayer.positionStream;
  Stream<Duration?> get durationStream => audioPlayer.durationStream;

  // Joriy pozitsiyani olish
  Duration get currentPosition => audioPlayer.position;
  Duration? get totalDuration => audioPlayer.duration;

  // Muayyan pozitsiyaga o'tish
  Future<void> seekTo(Duration position) async {
    await audioPlayer.seek(position);
  }

  // Ovoz balandligini boshqarish
  Future<void> setVolume(double volume) async {
    await audioPlayer.setVolume(volume.clamp(0.0, 1.0));
  }

  // Tezlikni boshqarish
  Future<void> setSpeed(double speed) async {
    await audioPlayer.setSpeed(speed.clamp(0.25, 2.0));
  }

  // Shuffle va repeat rejimlarini boshqarish
  Future<void> setShuffleMode(bool enabled) async {
    await audioPlayer.setShuffleModeEnabled(enabled);
  }

  Future<void> setLoopMode(LoopMode loopMode) async {
    await audioPlayer.setLoopMode(loopMode);
  }

  // Qo'shiq ma'lumotlarini formatlash
  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  // Progress foizini hisoblash
  double get progress {
    final duration = totalDuration;
    final position = currentPosition;
    if (duration == null || duration.inMilliseconds == 0) return 0.0;
    return position.inMilliseconds / duration.inMilliseconds;
  }

  // Qo'shiqni to'xtatish va tozalash
  Future<void> stopSong() async {
    await audioPlayer.stop();
    currentIndex.value = -1;
    isPlaying.value = false;
  }

  // Barcha ValueNotifier'larni tozalash
  void dispose() {
    audioPlayer.dispose();
    songs.dispose();
    currentIndex.dispose();
    isPlaying.dispose();
  }
}