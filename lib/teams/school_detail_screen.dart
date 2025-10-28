import 'package:flutter/material.dart';
import '../services/models.dart';
import '../players/player_detail_screen.dart';

class SchoolDetailScreen extends StatelessWidget {
  final School school;
  const SchoolDetailScreen({super.key, required this.school});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(school.name)),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.location_city),
            title: Text('${school.city} • ${school.conference}'),
            subtitle: Text('Roster: ${school.roster.length} • Games: ${school.schedule.length}'),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(12),
            child: Text('Roster', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          ...school.roster.map((p) => ListTile(
                title: Text(p.name),
                subtitle: Text('${p.pos} • #${p.number} • ${p.year}'),
                trailing: Text('${p.ppg.toStringAsFixed(1)} PPG'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PlayerDetailScreen(player: p, school: school),
                    ),
                  );
                },
              )),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(12),
            child: Text('Schedule', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          ...school.schedule.map((g) => ListTile(
                leading: const Icon(Icons.event),
                title: Text(g.home
                    ? '${g.opponent} @ ${school.name}'
                    : '${school.name} @ ${g.opponent}'),
                subtitle: Text('${g.status} • ${g.date.month}/${g.date.day}/${g.date.year}'),
              )),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
