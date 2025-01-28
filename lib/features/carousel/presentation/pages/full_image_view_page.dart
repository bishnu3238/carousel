import 'dart:io';

import 'package:carousel/features/carousel/presentation/state/full_image_view_provider.dart';
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
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _scrollToThumbnail(isInitialScroll: true));
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
      final newPageIndex = _pageController.page!.round();
      if (newPageIndex != _currentPageIndex) {
        setState(() {
          _currentPageIndex = newPageIndex;
        });
        _scrollToThumbnail();
      }
    }
  }

  void _scrollToThumbnail({bool isInitialScroll = false}) {
    if (_scrollController.hasClients && _currentPageIndex < _thumbnailKeys.length) {
      final keyContext = _thumbnailKeys[_currentPageIndex].currentContext;

      if (keyContext != null) {
        final renderObject = keyContext.findRenderObject();
        if (renderObject != null) {
          _scrollController.position.ensureVisible(
            renderObject,
            duration: isInitialScroll
                ? const Duration(milliseconds: 0) // No animation on the initial scroll
                : const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      } else if (isInitialScroll) {
        // Directly scroll based on index and thumbnail size if context is not ready.
        const thumbnailWidth = 80.0 + 10.0; // Thumbnail width + margin
        final offset = _currentPageIndex * thumbnailWidth;
        _scrollController.jumpTo(offset);
      }
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
      body: Consumer<FullImageViewProvider>(builder: (context, provider, _) {
        return Stack(
          children: [
            GestureDetector(
              onTap: provider.toggleIsFullScreen,
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
            provider.isFullScreen
                ? Positioned(
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
                  )
                : const SizedBox(),
            provider.isFullScreen
                ? Positioned(
                    bottom: 10,
                    left: 0,
                    right: 0,
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            SizedBox(
                              height: 130,
                              child: ListView.builder(
                                controller: _scrollController,
                                findChildIndexCallback: (d) {},
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
                                            height: 120,
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
                  )
                : const SizedBox(),
          ],
        );
      }),
    );
  }
}
