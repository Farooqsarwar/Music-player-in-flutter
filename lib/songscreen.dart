import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';

class Open extends StatefulWidget {
  const Open({
    Key? key,
    this.title,
    this.filePath,
    this.songs,
    this.currentIndex,
  }) : super(key: key);

  final String? title;
  final String? filePath;
  final List<SongModel>? songs;
  final int? currentIndex;

  @override
  State<Open> createState() => _OpenState();
}

class _OpenState extends State<Open> with SingleTickerProviderStateMixin {
  double _currentSliderValue = 0.0;
  final AudioPlayer _audioPlayer = AudioPlayer();
  Duration _songDuration = Duration.zero;
  late AnimationController _controller;
  late Animation<double> _animation;
  late int _currentSongIndex;
  String? _currentTitle;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller)
      ..addListener(() {
        if (mounted) setState(() {});
      });

    _controller.repeat();

    _currentSongIndex = widget.currentIndex ?? 0;
    _currentTitle = widget.title ?? "No Title";

    if (widget.filePath != null) {
      _loadAudio(widget.filePath!);
    }

    _audioPlayer.positionStream.listen((position) {
      if (mounted) {
        setState(() {
          _currentSliderValue = position.inMilliseconds.toDouble();
        });
      }
    });

    _audioPlayer.durationStream.listen((duration) {
      if (mounted) {
        setState(() {
          _songDuration = duration ?? Duration.zero;
        });
      }
    });
  }

  Future<void> _loadAudio(String filePath) async {
    try {
      await _audioPlayer.setFilePath(filePath);
      setState(() {
        _songDuration = _audioPlayer.duration ?? Duration.zero;
        _currentTitle = widget.songs?[_currentSongIndex].title ?? "No Title";
      });
    } catch (e) {
      print("Error loading audio: $e");
    }
  }

  void _playPreviousSong() {
    if (_currentSongIndex > 0) {
      setState(() {
        _currentSongIndex--;
        _currentTitle = widget.songs?[_currentSongIndex].title ?? "No Title";
      });
      _loadAudio(widget.songs![_currentSongIndex].data);
    }
  }

  void _playNextSong() {
    if (_currentSongIndex < (widget.songs!.length - 1)) {
      setState(() {
        _currentSongIndex++;
        _currentTitle = widget.songs?[_currentSongIndex].title ?? "No Title";
      });
      _loadAudio(widget.songs![_currentSongIndex].data);
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _controller.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  Widget _buildIconButton(IconData icon, VoidCallback onPressed) {
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
        onPressed: onPressed,
        icon: Icon(icon),
        color: Colors.white54,
      ),
    );
  }

  Widget _buildRotatingAvatar() {
    return Transform.rotate(
      angle: _animation.value * 2.0 * 3.1415927,
      child: Container(
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
      ),
    );
  }

  Widget _buildPlayPauseButton() {
    return Container(
      height: 70,
      width: 70,
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(90),
      ),
      child: IconButton(
        iconSize: 50,
        icon: Icon(
          _audioPlayer.playing ? Icons.pause : Icons.play_arrow,
          color: Colors.white,
        ),
        onPressed: () {
          if (_audioPlayer.playing) {
            _audioPlayer.pause();
          } else {
            _audioPlayer.play();
          }
          setState(() {});
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomLeft,
          colors: [Color(0xff181a1d), Color(0xff33383d)],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 75, left: 30, right: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildIconButton(Icons.arrow_back_ios, () {
                    Navigator.pop(context);
                  }),
                  _buildIconButton(Icons.menu_open_sharp, () {
                    print("Menu button pressed");
                  }),
                ],
              ),
            ),
            const SizedBox(height: 10),
            _buildRotatingAvatar(),
            const SizedBox(height: 40),
            Text(
              _currentTitle ?? "No Title",
              style: const TextStyle(color: Colors.white, fontSize: 20),
            ),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.only(left: 30, right: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDuration(
                      Duration(milliseconds: _currentSliderValue.toInt()),
                    ),
                    style: const TextStyle(color: Colors.white54),
                  ),
                  Text(
                    _formatDuration(_songDuration),
                    style: const TextStyle(color: Colors.white54),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: Slider(
                value: _currentSliderValue,
                max: _songDuration.inMilliseconds.toDouble(),
                activeColor: Colors.red,
                inactiveColor: Colors.black,
                onChanged: (double value) {
                  setState(() {
                    _currentSliderValue = value;
                  });
                  _audioPlayer.seek(Duration(milliseconds: value.toInt()));
                },
              ),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.only(left: 15, right: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildIconButton(Icons.fast_rewind, _playPreviousSong),
                  _buildPlayPauseButton(),
                  _buildIconButton(Icons.fast_forward, _playNextSong),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
