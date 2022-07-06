import 'package:flutter/material.dart';

class Loader extends StatelessWidget {
  final bool isFullScreen;
  final bool isfullScreenWithBackgroundTransparent;
  final bool isLoading;

  const Loader(
      {Key? key,
      this.isFullScreen = false,
      this.isfullScreenWithBackgroundTransparent = false,
      this.isLoading = false})
      : super(key: key);

  Widget Spinner() {
    return const Center(child: CircularProgressIndicator());
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      if (!isFullScreen) {
        return Spinner();
      } else {
        return Container(
          color: isfullScreenWithBackgroundTransparent
              ? Colors.black54
              : Colors.white,
          child: Spinner(),
        );
      }
    } else {
      return const SizedBox(
        height: 0,
        width: 0,
      );
    }
  }
}
