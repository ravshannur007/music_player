import 'package:flutter/material.dart';
import 'package:music_player/controller/audio_controller.dart';
import 'package:music_player/utils/custom_text_styles.dart';
import 'package:music_player/widgets/bottom_player.dart';
import 'package:music_player/widgets/my_button.dart';
import 'package:music_player/widgets/song_list_item.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final audioController = AudioController();
  bool _hasPermission = false;

  Future<void> _checkPermissionAndRequest() async{
    final permission = await Permission.audio.status;
    if(permission.isGranted) {
      setState(() => _hasPermission = true);
      await audioController.loadSongs();
    }else{
      final result = await Permission.audio.request();
      setState(() => _hasPermission = true);
      if(result.isGranted){
        await audioController.loadSongs();
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _checkPermissionAndRequest();
  }

  @override
  Widget build(BuildContext context) {
    backgroundColor:
    const Color(0xFFE0E5EC);
    return Scaffold(
      appBar: AppBar(
        title: RichText(
          text: TextSpan(
            children: [
              WidgetSpan(
                child: Text(
                  "Tune",
                  style: myTextStyle24(
                    fontWeight: FontWeight.bold,
                    fontColor: Colors.black,
                  ),
                ),
              ),
              WidgetSpan(
                child: Text(
                  "Sync",
                  style: myTextStyle24(
                    fontWeight: FontWeight.w900,
                    fontColor: Colors.greenAccent,
                  ),
                ),
              ),
            ],
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.all(4.0),
          child: MyButton(child: Center(child: Icon(Icons.person)), onPress: (){}),
        ),
        toolbarHeight: 80,
        actions: [
          MyButton(child: Icon(Icons.favorite_border), onPress: (){}) ,
          SizedBox(width: 16,),
          MyButton(child: Icon(Icons.settings), onPress: (){}) ,
          SizedBox(width: 12,)
        ],
      ),

      body: ValueListenableBuilder(
        valueListenable: audioController.songs,
        builder: (context, songs, child) {
          if (songs.isEmpty) {
            return Center(child: CircularProgressIndicator(color: Colors.greenAccent , strokeWidth: 6,));
          }
          return ListView.builder(
            itemCount: songs.length,
            itemBuilder: (context, index) {
              return SongListItem(song: songs[index], index: index);
            },
          );
        },
      ),
      bottomSheet: BottomPlayer(),
    );
  }


}
