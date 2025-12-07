import 'package:flutter/material.dart';
import '../services/models.dart';
import '../services/nc_loader.dart';
import 'school_detail_screen.dart';

class TeamsScreen extends StatefulWidget {
  const TeamsScreen({super.key});
  @override
  State<TeamsScreen> createState() => _TeamsScreenState();
}

class _TeamsScreenState extends State<TeamsScreen> {
  late Future<List<School>> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadTeams();
  }

  Future<List<School>> _loadTeams() async {
    final data = await NCLoader.load();
    return data.schools;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<School>>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        final teams = snap.data ?? [];
        if (teams.isEmpty) return const Center(child: Text('No teams found.'));
        return GridView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: teams.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1.2,
          ),
          itemBuilder: (_, i) {
            final t = teams[i];
            return Card(
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => SchoolDetailScreen(school: t)),
                  );
                },
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(t.name,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text(t.conference, style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
