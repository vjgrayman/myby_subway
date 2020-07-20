import 'package:flutter/material.dart';
import 'page_subway_info.dart';

void main() => runApp(mybySubway());

class mybySubway extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '지하철 실시간 정보',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Color(0xFF522546),
        fontFamily: 'Noto Sans KR',
      ),
      home: MainPage(),
    );
  }
}
