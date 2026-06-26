import 'dart:io';
import 'package:sokon/l10n/app_localizations.dart';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:sokon/core/utils/app_colors.dart';
import 'package:video_player/video_player.dart';

class AppVideoPlayer extends StatefulWidget {
  const AppVideoPlayer.file(
    String path, {
    super.key,
    this.placeholder,
    this.height,
    this.borderRadius,
    this.autoPlay = false,
  })  : filePath = path,
        networkUrl = null;

  const AppVideoPlayer.network(
    String url, {
    super.key,
    this.placeholder,
    this.height,
    this.borderRadius,
    this.autoPlay = false,
  })  : networkUrl = url,
        filePath = null;

  final String? filePath;
  final String? networkUrl;
  final Widget? placeholder;
  final double? height;
  final BorderRadius? borderRadius;
  final bool autoPlay;

  @override
  State<AppVideoPlayer> createState() => _AppVideoPlayerState();
}

class _AppVideoPlayerState extends State<AppVideoPlayer> {
  static const Duration _androidProgressDelay = Duration(days: 1);

  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  int _loadVersion = 0;
  bool _isLoading = true;
  String? _errorMessage;

  String get _sourceKey => widget.filePath ?? widget.networkUrl ?? '';

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  @override
  void didUpdateWidget(covariant AppVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    final hasSourceChanged =
        oldWidget.filePath != widget.filePath ||
        oldWidget.networkUrl != widget.networkUrl;

    if (hasSourceChanged) {
      _initializePlayer();
    }
  }

  Future<void> _initializePlayer() async {
    final loadVersion = ++_loadVersion;
    await _disposeControllers();

    if (!mounted || loadVersion != _loadVersion) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final videoPlayerController = _createVideoController();

    try {
      debugPrint("Initializing video player for: ${_sourceKey}");
      // Use a timeout to prevent hanging forever
      await videoPlayerController.initialize().timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw Exception("Video initialization timeout"),
      );
      debugPrint("Video player initialized successfully");

      if (!mounted || loadVersion != _loadVersion) {
        await videoPlayerController.dispose();
        return;
      }

      final chewieController = ChewieController(
        videoPlayerController: videoPlayerController,
        autoPlay: widget.autoPlay,
        looping: false,
        allowFullScreen: true,
        allowMuting: true,
        allowPlaybackSpeedChanging: true,
        showControlsOnInitialize: false,
        materialProgressColors: ChewieProgressColors(
          playedColor: AppColors.primaryColor,
          handleColor: AppColors.primaryColor,
          backgroundColor: AppColors.grayColor.withOpacity(0.25),
          bufferedColor: AppColors.whiteColor.withOpacity(0.35),
        ),
        // Use an empty placeholder after initialization is done
        placeholder: Container(color: Colors.black),
        errorBuilder: (context, errorMessage) {
          return _buildShell(
            child: _buildErrorState(errorMessage),
          );
        },
      );

      if (!mounted || loadVersion != _loadVersion) {
        chewieController.dispose();
        await videoPlayerController.dispose();
        return;
      }

      setState(() {
        _videoPlayerController = videoPlayerController;
        _chewieController = chewieController;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Video initialization failed: $e");
      await videoPlayerController.dispose();
      if (!mounted || loadVersion != _loadVersion) return;

      setState(() {
        _errorMessage = AppLocalizations.of(context)?.videoPlaybackUnavailable ?? "Video playback unavailable";
        _isLoading = false;
      });
    }
  }

  VideoPlayerController _createVideoController() {
    if (widget.filePath != null) {
      return VideoPlayerController.file(File(widget.filePath!));
    }

    return VideoPlayerController.networkUrl(Uri.parse(widget.networkUrl!));
  }

  Future<void> _disposeControllers() async {
    final chewieController = _chewieController;
    final videoPlayerController = _videoPlayerController;

    _chewieController = null;
    _videoPlayerController = null;

    // Dispose Chewie first. By default, Chewie disposes the video player controller
    // unless autoDispose is set to false. 
    chewieController?.dispose();
    
    // Explicitly dispose the video player controller as well, just in case,
    // or if Chewie wasn't fully initialized.
    try {
      await videoPlayerController?.dispose();
    } catch (e) {
      debugPrint("Error disposing video controller: $e");
    }
  }

  Widget _buildShell({required Widget child}) {
    return Container(
      clipBehavior: Clip.antiAlias,
      height: widget.height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.pureBlack,
        borderRadius: widget.borderRadius ?? BorderRadius.circular(20),
      ),
      child: child,
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        color: AppColors.whiteColor,
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.whiteColor,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (_isLoading) {
      return _buildShell(child: _buildLoadingState());
    }

    if (_errorMessage != null) {
      return _buildShell(child: _buildErrorState(_errorMessage!));
    }

    final chewieController = _chewieController;
    if (chewieController == null) {
      return _buildShell(child: _buildErrorState(l10n.videoPlaybackFailed));
    }

    return Column(
      key: ValueKey(_sourceKey),
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildShell(
          child: Chewie(
            controller: chewieController,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    final chewieController = _chewieController;
    final videoPlayerController = _videoPlayerController;

    _chewieController = null;
    _videoPlayerController = null;

    chewieController?.dispose();
    videoPlayerController?.dispose();
    super.dispose();
  }
}
