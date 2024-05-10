import 'package:flutter/material.dart';
import 'package:kinohub/components/custom_page_route.dart';
import 'package:kinohub/views/user_profile_view.dart';

class PremiumView extends StatefulWidget {
  const PremiumView({super.key});

  @override
  State<PremiumView> createState() => _PremiumViewState();
}

class _PremiumViewState extends State<PremiumView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Преміум-підписка',
          style: TextStyle(
            color: Color(0xFFD3D3D3),
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: const Color(0xFFD3D3D3),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              CustomPageRoute(
                builder: (context) => const UserProfile(),
              ),
            );
          },
        ),
      ),
    );
  }
}
