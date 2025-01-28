import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/state/wallpaper_provider.dart';
import '../../domain/usecases/wallpaper_usecase.dart';
import '../widgets/sparkly_painter.dart';

class FullImageViewPage extends StatefulWidget {
  final String imagePath;

  const FullImageViewPage({super.key, required this.imagePath});

  @override
  State<FullImageViewPage> createState() => _FullImageViewPageState();
}

class _FullImageViewPageState extends State<FullImageViewPage>
    with TickerProviderStateMixin {
  late WallpaperProvider _wallpaperProvider;
  final WallpaperUseCase _wallpaperUseCase = sl();
  late PageController _pageController;
  late ScrollController _scrollController;
  int _currentPageIndex = 0;
  final List<GlobalKey> _thumbnailKeys = [];

  //
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _showOverlay = false;
  List<Icon> _sparkleIcons = [];

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _wallpaperProvider = Provider.of<WallpaperProvider>(context, listen: false);

    // Initialize page controller at the correct index.
    _currentPageIndex = _wallpaperProvider.wallpapers.indexWhere(
      (wallpaper) => wallpaper.path == widget.imagePath,
    );
    _pageController = PageController(initialPage: _currentPageIndex)
      ..addListener(_onPageChanged);
    _scrollController = ScrollController();

    // Initialize thumbnail keys for animations.
    for (int i = 0; i < _wallpaperProvider.wallpapers.length; i++) {
      _thumbnailKeys.add(GlobalKey());
    }

    ///
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _showOverlay = false; // Hide overlay after animation completes
        });
        _animationController.reset();
      }
      if (status == AnimationStatus.forward) {
        setState(() {
          _showOverlay = true;
        });
      }
    });
    _sparkleIcons = [
      const Icon(Icons.star, size: 10, color: Colors.amber),
      const Icon(Icons.star, size: 12, color: Colors.orangeAccent),
      const Icon(Icons.star, size: 8, color: Colors.yellow),
      const Icon(Icons.star, size: 14, color: Colors.amber),
      const Icon(Icons.star, size: 10, color: Colors.orangeAccent),
      const Icon(Icons.star, size: 12, color: Colors.yellow),
    ];
  }

  void _startAnimation() {
    _animationController.forward();
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _pageController.removeListener(_onPageChanged);
    _pageController.dispose();
    _scrollController.dispose();
    //
    _animationController.dispose();

    super.dispose();
  }

  void _onPageChanged() {
    if (_pageController.page != null) {
      setState(() {
        _currentPageIndex = _pageController.page!.round();
      });
      _scrollToThumbnail();
    }
  }

  void _scrollToThumbnail() {
    if (_scrollController.hasClients) {
      final screenWidth = MediaQuery.of(context).size.width;
      _scrollController.animateTo(
        _currentPageIndex * (screenWidth * 0.22),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _removeWallpaper(int index) async {
    final wallpaper = _wallpaperProvider.wallpapers[index];
    final result = await _wallpaperUseCase.removeWallpaper(wallpaper);
    result.fold(
      (failure) {
        // Handle error (e.g., show a snackbar or log).
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to remove wallpaper')),
        );
      },
      (success) {
        if (success) {
          _wallpaperProvider.removeWallpaper(wallpaper);
          if (mounted) {
            Navigator.of(context).pop();
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final wallpapers = _wallpaperProvider.wallpapers;

    return Scaffold(
      body: Stack(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: PageView.builder(
              controller: _pageController,
              physics: const BouncingScrollPhysics(),
              itemCount: wallpapers.length,
              itemBuilder: (context, index) {
                final wallpaper = wallpapers[index];
                return InteractiveViewer(
                  clipBehavior: Clip.none,
                  maxScale: 5,
                  child: Image.file(
                    File(wallpaper.path),
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    key: ValueKey<String>(wallpaper.path),
                  ),
                );
              },
            ),
          ),
          Positioned(
            top: 30,
            left: 10,
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                ),
                const Text(
                  'Preview',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Stack(
                  children: [
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        controller: _scrollController,
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: wallpapers.length,
                        itemBuilder: (context, index) {
                          final wallpaper = wallpapers[index];
                          final isSelected = index == _currentPageIndex;
                          return GestureDetector(
                            key: _thumbnailKeys[index],
                            onTap: () {
                              _startAnimation();
                              _pageController.animateToPage(
                                index,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 5),
                              padding: const EdgeInsets.all(1),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [Colors.blue, Colors.purple],
                                ),
                                border: isSelected
                                    ? Border.all(color: Colors.white, width: 2)
                                    : null,
                              ),
                              child: Opacity(
                                opacity: isSelected ? 1.0 : 0.7,
                                child: ClipRRect(
                                  borderRadius:
                                      const BorderRadius.all(Radius.circular(10)),
                                  child: Image.file(
                                    File(wallpaper.path),
                                    fit: BoxFit.cover,
                                    width: 80,
                                    height: 80,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    if (_showOverlay) // Show the overlay only when _showOverlay is true
                      Positioned.fill(
                        child: AnimatedBuilder(
                          animation: _animation,
                          builder: (context, child) {
                            return CustomPaint(
                              painter: SparklePainterRotation(
                                animationValue: _animation.value,
                                iconSize: 30.0,
                                sparkleIcons: _sparkleIcons,
                              ), // Assuming a base size of 24 for icon
                            );
                          },
                        ),
                      ),
                  ],
                ),
                TextButton.icon(
                  style: TextButton.styleFrom(foregroundColor: Colors.white),
                  onPressed: () => _removeWallpaper(_currentPageIndex),
                  icon: const Icon(Icons.delete),
                  label: const Text('Remove'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
