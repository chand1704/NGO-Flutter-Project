import 'dart:async';

import 'package:flutter/material.dart';

class AutoSlider extends StatefulWidget {
  const AutoSlider({super.key});

  @override
  _AutoSliderState createState() => _AutoSliderState();
}

class _AutoSliderState extends State<AutoSlider> {
  late final PageController _controller;
  Timer? _timer;
  int _currentPage = 0;

  final List<String> images = [
    'assets/images/slider1.jpg',
    'assets/images/slidertree1.jpeg',
    'assets/images/slider2.jpeg',
    'assets/images/slidertree2.jpeg',
  ];

  @override
  void initState() {
    super.initState();
    // 1. viewportFraction makes the side images slightly visible
    _controller = PageController(viewportFraction: 0.9);

    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_controller.hasClients) {
        _currentPage = (_currentPage + 1) % images.length;
        _controller.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.fastOutSlowIn,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 220, // Slightly more compact
          child: PageView.builder(
            controller: _controller,
            itemCount: images.length,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (context, index) {
              return AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  // 2. Subtle scaling effect for the active page
                  double value = 1.0;
                  if (_controller.position.haveDimensions) {
                    value = _controller.page! - index;
                    value = (1 - (value.abs() * 0.1)).clamp(0.0, 1.0);
                  }
                  return Center(
                    child: SizedBox(
                      height: Curves.easeInOut.transform(value) * 220,
                      width:
                          Curves.easeInOut.transform(value) * double.infinity,
                      child: child,
                    ),
                  );
                },
                child: _buildSliderItem(images[index]),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        // 3. Dynamic Animated Indicators
        _buildIndicators(),
      ],
    );
  }

  Widget _buildSliderItem(String imagePath) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(imagePath, fit: BoxFit.cover),
            // 4. Subtle Gradient Overlay for depth
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.4),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(images.length, (index) {
        bool isActive = _currentPage == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 8,
          width: isActive ? 24 : 8, // Grows when active
          decoration: BoxDecoration(
            color: isActive ? Colors.indigo : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(10),
          ),
        );
      }),
    );
  }
}
