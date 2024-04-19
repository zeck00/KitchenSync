// ignore_for_file: prefer_const_constructors_in_immutables, library_private_types_in_public_api, file_names, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:kitchensync/screens/welcomePage.dart';
import 'package:kitchensync/styles/AppColors.dart';
import 'package:kitchensync/styles/AppFonts.dart';
import 'package:lottie/lottie.dart';
import '../styles/size_config.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'dart:async';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  Timer? _pageChangeTimer;
  int currentPage = 0; // To track the current page index
  bool showLoginPage = true;

  void toggleScreens() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  void _navigateToLogin(BuildContext context) {
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) => WelcomeScreen(),
    ));
  }

  void _startAutoScroll() {
    _pageChangeTimer = Timer.periodic(Duration(seconds: 8), (Timer timer) {
      int nextPage = _controller.page!.round() + 1;
      if (nextPage < 3) {
        _controller.animateToPage(nextPage,
            duration: Duration(milliseconds: 300), curve: Curves.easeIn);
      } else {
        timer.cancel(); // Optionally restart or stop the timer at the last page
      }
    });
  }

  @override
  void dispose() {
    _pageChangeTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(propWidth(16)), // Adjust the padding if needed
        child: Column(
          children: [
            SizedBox(height: propHeight(20)),
            Image.asset(
              'assets/images/logo.png',
              width: propWidth(40),
              height: propHeight(40),
            ),
            Expanded(
              child: PageView(
                pageSnapping: true,
                scrollBehavior: MaterialScrollBehavior(),
                physics: BouncingScrollPhysics(
                    decelerationRate: ScrollDecelerationRate.fast),
                controller: _controller,
                onPageChanged: (int page) {
                  setState(() {
                    currentPage = page;
                  });
                  _pageChangeTimer?.cancel(); // Cancel the current timer
                  _startAutoScroll(); // Restart the auto-scroll timer
                },
                children: [
                  OnboardingContentWidget(
                    h: 400,
                    w: 400,
                    lottieAsset:
                        'https://lottie.host/823ef0b6-cc41-43ed-b982-bbd59a467fe1/BpVtuZkIEM.json',
                    title: 'Welcome to KitchenSync™',
                    description: 'Keep your kitchen items synchronized!',
                  ),
                  OnboardingContentWidget(
                    h: 400,
                    w: 400,
                    lottieAsset:
                        'https://lottie.host/26395ade-aa0f-43af-a92d-c567e05884b5/892tFK0NcC.json',
                    title: 'Plan Your Meals Easily',
                    description: 'Plan your meals and get suggestions!',
                  ),
                  OnboardingContentWidget(
                    h: 300,
                    w: 400,
                    lottieAsset:
                        'https://lottie.host/e2497655-a2bf-4d14-b609-fc9900314a40/fHhxWNyK06.json',
                    title: 'Schedule Your Donations',
                    description: 'Schedule donations, help someone in need!',
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                currentPage < 2
                    ? TextButton(
                        onPressed: () {
                          _navigateToLogin(context);
                        },
                        child: Text(
                          'Skip',
                          style: AppFonts.servicename,
                        ),
                      )
                    : Text('                  '),
                SmoothPageIndicator(
                  controller: _controller,
                  count: 3,
                  effect: ExpandingDotsEffect(
                      activeDotColor: AppColors.primary,
                      dotColor: AppColors.grey2,
                      dotHeight: 20,
                      dotWidth: 20),
                ),
                TextButton(
                  onPressed: () {
                    if (currentPage < 2) {
                      _controller.nextPage(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeIn);
                    } else {
                      _navigateToLogin(context);
                    }
                  },
                  child: Text(
                    currentPage < 2 ? 'Next' : 'Done',
                    style: AppFonts.servicename,
                  ),
                ),
              ],
            ),
            SizedBox(height: propHeight(24)),
          ],
        ),
      ),
    );
  }
}

class OnboardingContentWidget extends StatelessWidget {
  final String lottieAsset;
  final String title;
  final String description;
  final double w;
  final double h;

  OnboardingContentWidget(
      {super.key,
      required this.lottieAsset,
      required this.title,
      required this.description,
      required this.w,
      required this.h});

  @override
  Widget build(BuildContext context) {
    initSizeConfig(context); // Make sure you call this if needed
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Expanded(child: Container()),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(propHeight(17)),
            color: AppColors.grey2.withAlpha(0),
          ),
          alignment: Alignment.center,
          height: propHeight(600),
          width: propWidth(380),
          child: Stack(
            children: [
              Lottie.network(
                animate: true,
                repeat: true,
                lottieAsset,
                width: propWidth(w), // Use your propWidth/propHeight as needed
                height: propHeight(h),
                fit: BoxFit.fill,
              ),
            ],
          ),
        ),
        Column(children: [
          Text(title, style: AppFonts.onBoardtxt),
          Text(description, style: AppFonts.onBoardtxt1)
        ]),
        Expanded(child: Container()),
      ],
    );
  }
}
