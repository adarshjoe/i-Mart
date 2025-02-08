





import 'dart:async'; // Import Timer
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_mart/controllers/banner_controller.dart';

class BannerArea extends StatefulWidget {
  const BannerArea({Key? key}) : super(key: key);

  @override
  _BannerAreaState createState() => _BannerAreaState();
}

class _BannerAreaState extends State<BannerArea> {
  final BannerController bannerController = Get.find<BannerController>();
  late PageController _pageController;
  late Timer _timer;
  int _currentPage = 0;
  List<String> _bannerUrls = [];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 1); // Start with the first actual banner
    _fetchBanners(); // Fetch banners when initializing
  }

  Future<void> _fetchBanners() async {
    final bannerUrls = await bannerController.getBannerUrls().first; // Assuming it returns a Stream<List<String>>
    setState(() {
      _bannerUrls = bannerUrls; // Set the state with fetched banners
    });
    _startAutoSlide();
  }

  void _startAutoSlide() {
    _timer = Timer.periodic(Duration(seconds: 10), (Timer timer) {
      if (_currentPage < _bannerUrls.length + 1) {
        _currentPage++;
      } else {
        _currentPage = 1; // Reset to first actual banner
      }
      _pageController.animateToPage(
        _currentPage,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // Stop the timer when the widget is disposed
    _pageController.dispose(); // Dispose the PageController
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double spacing = MediaQuery.of(context).size.width < 600 ? 16.0 : 32.0;

    return Container(
      width: MediaQuery.of(context).size.width,
      height: 170, // Adjust the banner height as needed
      padding: EdgeInsets.symmetric(horizontal: spacing),
      decoration: BoxDecoration(
        color: Color(0xFFF7F7F7),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 2), // Add a subtle shadow
          ),
        ],
      ),
      child: _bannerUrls.isEmpty
          ? Center(
              child: CircularProgressIndicator(color: Colors.blue),
            )
          : Stack(
              alignment: Alignment.bottomCenter,
              children: [
                PageView.builder(
                  controller: _pageController,
                  itemCount: _bannerUrls.length + 2, // Add two for the looping effect
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return BannerWidget(imageUrl: _bannerUrls.last); // Show last banner
                    } else if (index == _bannerUrls.length + 1) {
                      return BannerWidget(imageUrl: _bannerUrls.first); // Show first banner
                    } else {
                      return BannerWidget(imageUrl: _bannerUrls[index - 1]); // Actual banners
                    }
                  },
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                ),
                _buildPageIndicator(_bannerUrls.length),
              ],
            ),
    );
  }

  Widget _buildPageIndicator(int pageCount) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(pageCount, (index) {
          return Container(
            width: 8.0,
            height: 8.0,
            margin: EdgeInsets.symmetric(horizontal: 4.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _currentPage == index + 1 ? Colors.blue : Colors.grey, // Active indicator color
            ),
          );
        }),
      ),
    );
  }
}

class BannerWidget extends StatelessWidget {
  final String imageUrl;

  BannerWidget({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(9),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => Center(
          child: CircularProgressIndicator(),
        ),
        errorWidget: (context, url, error) => Icon(
          Icons.error,
        ),
      ),
    );
  }
}
