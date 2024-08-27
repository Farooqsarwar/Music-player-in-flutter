import 'package:audioplayer/songscreen.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';

class Songs extends StatefulWidget {
  const Songs({Key? key}) : super(key: key);

  @override
  _SongsState createState() => _SongsState();
}

class _SongsState extends State<Songs> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final OnAudioQuery _audioQuery = OnAudioQuery();
  List<SongModel> _audioFiles = [];

  @override
  void initState() {
    super.initState();
    _fetchAudioFiles();
  }

  Future<void> _fetchAudioFiles() async {
    if (await Permission.storage.isGranted) {
      await _scanAudioFiles();
    } else {
      PermissionStatus status = await Permission.storage.request();
      if (status.isGranted) {
        await _scanAudioFiles();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Storage permission is required")),
        );
      }
    }
  }

  Future<void> _scanAudioFiles() async {
    final songs = await _audioQuery.querySongs();
    setState(() {
      _audioFiles = songs;
    });
  }

  void _navigateToOpenScreen(String title, String filePath, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Open(
          title: title,
          filePath: filePath,
          songs: _audioFiles,
          currentIndex: index,
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomLeft,
          colors: [Color(0xff181a1d), Color(0xff33383d)],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          surfaceTintColor: Colors.transparent,
          backgroundColor: Colors.transparent,
          title: const Center(
            child: Text(
              "Songs List",
              style: TextStyle(
                color: Color(0xff707477),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        body: Column(
          children: [
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildIconButton(Icons.favorite, "Favorite button pressed"),
                _buildAvatar(),
                _buildIconButton(Icons.more_horiz, "More button pressed"),
              ],
            ),
            const SizedBox(height: 30),
            Expanded(
              child: _audioFiles.isEmpty
                  ? const Center(
                child: Text(
                  "No audio files found.",
                  style: TextStyle(color: Colors.white),
                ),
              )
                  : songlist(context, _audioFiles),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton(IconData icon, String message) {
    return Container(
      height: 50,
      width: 50,
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(90),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 20,
            spreadRadius: 10,
            offset: Offset(0, 0),
          ),
        ],
      ),
      child: IconButton(
        onPressed: () {
          print(message);
        },
        icon: Icon(icon),
        color: Colors.white54,
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(90),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            spreadRadius: 10,
            offset: Offset(0, 0),
          ),
        ],
      ),
      child: const CircleAvatar(
        backgroundColor: Colors.transparent,
        backgroundImage: AssetImage("assets/rose.jpg"),
        radius: 90,
      ),
    );
  }

  Widget songlist(BuildContext context, List<SongModel> songs) {
    return ListView.builder(
      itemCount: songs.length,
      itemBuilder: (context, index) {
        final song = songs[index];
        return Column(
          children: [
            ListTile(
              title: Text(
                song.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                song.artist ?? "Unknown Artist",
                style: const TextStyle(color: Colors.white54),
              ),
              trailing: Container(
                height: 45,
                width: 45,
                decoration: BoxDecoration(
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.white10,
                        blurRadius: 10,
                        spreadRadius: 10,
                        offset: Offset(0, 0))
                  ],
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(90),
                ),
                child: InkWell(
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    size: 30,
                    color: Colors.white,
                  ),
                  onTap: () {
                    _navigateToOpenScreen(song.title, song.data, index);
                  },
                ),
              ),
            ),
            const SizedBox(
              width: 300,
              child: Divider(color: Colors.white),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}