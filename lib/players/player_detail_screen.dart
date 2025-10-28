import 'package:flutter/material.dart';
import '../services/models.dart';

class PlayerDetailScreen extends StatelessWidget {
  final Player player;
  final School school;
  const PlayerDetailScreen({super.key, required this.player, required this.school});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(player.name)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          '${player.name}\n'
          'School: ${school.name}\n'
          'Position: ${player.pos}\n'
          'Jersey: #${player.number}\n'
          'Height: ${player.height}\n'
          'Year: ${player.year}\n\n'
          'PPG: ${player.ppg.toStringAsFixed(1)}   '
          'RPG: ${player.rpg.toStringAsFixed(1)}   '
          'APG: ${player.apg.toStringAsFixed(1)}',
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
