import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: MyVideoPlayer(),
    );
  }
}

class MyVideoPlayer extends StatefulWidget {
  @override
  _MyVideoPlayerState createState() => _MyVideoPlayerState();
}

class _MyVideoPlayerState extends State<MyVideoPlayer> {
  late VideoPlayerController _controller;
  List<String> videoPaths = [
    'assets/your_video.mp4',
    // Add more video paths as needed
  ];
  int currentVideoIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  void _initializeController() {
    _controller = VideoPlayerController.asset(videoPaths[currentVideoIndex])
      ..initialize().then((_) {
        setState(() {});
        _controller.setLooping(true);
        _controller.play();
      });

    _controller.addListener(() {
      if (_controller.value.hasError) {
        print('VideoPlayerController error: ${_controller.value.errorDescription}');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Video Player'),
        actions: [
          IconButton(
            icon: Icon(Icons.playlist_play),
            onPressed: () {
              _showVideoListDialog();
            },
          ),
        ],
      ),
      body: _controller.value.isInitialized
          ? Center(
              child: AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              ),
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _controller.pause();
            _controller.seekTo(Duration(seconds: 0));
            _controller.play();
          });
        },
        child: Icon(Icons.replay),
      ),
    );
  }

  void _showVideoListDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select a Video'),
          content: Column(
            children: [
              for (int i = 0; i < videoPaths.length; i++)
                ListTile(
                  title: Text('Video ${i + 1}'),
                  onTap: () {
                    setState(() {
                      currentVideoIndex = i;
                      _controller.pause();
                      _controller.dispose(); // Dispose the old controller
                      _initializeController(); // Initialize a new controller
                      Navigator.pop(context);
                    });
                  },
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
