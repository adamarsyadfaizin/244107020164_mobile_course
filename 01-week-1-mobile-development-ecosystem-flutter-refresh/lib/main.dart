import 'package:flutter/material.dart';

void main() => runApp(const ProfileApp());

class ProfileApp extends StatelessWidget {
  const ProfileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: ProfileCard(),
        ),
      ),
    );
  }
}

class ProfileCard extends StatelessWidget {
  const ProfileCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.indigo.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const CircleAvatar(
                child: Icon(Icons.person),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Moch. Adam Arsyad Faizin',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text('Moch. Adam Arsyad Faizin'),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          const Row(
            children: [
              Expanded(
                child: Text('244107020164'),
              ),
              Text('244107020164'),
            ],
          ),

          const Row(
            children: [
              Expanded(
                child: Text('TI-3F'),
              ),
              Text('TI-3F'),
            ],
          ),

          const Row(
            children: [
              Expanded(
                child: Text('adamkull36@gmail.com'),
              ),
              Text('adamkull36@gmail.com'),
            ],
          ),
        ],
      ),
    );
  }
}