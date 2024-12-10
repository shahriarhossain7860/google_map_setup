import 'package:flutter/material.dart';


import 'map_screen.dart';

void main()
{
  runApp(googleMapApp());
}
class googleMapApp extends StatelessWidget {
  const googleMapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MapScreen(),
    );
  }


}
