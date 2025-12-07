import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

/// ===============================================================
/// MODELS
/// ===============================================================
class Player {
  final String id, name, pos, height, year;
  final int number;
  final double ppg, rpg, apg;
  final int? weightLbs; // optional

  Player({
    required this.id,
    required this.name,
    required this.pos,
    required this.number,
    required this.height,
    required this.year,
    this.ppg = 0,
    this.rpg = 0,
    this.apg = 0,
    this.weightLbs,
  });

  factory Player.fromJson(Map<String, dynamic> j) => Player(
        id: j['id'],
        name: j['name'],
        pos: j['pos'],
        number: j['number'],
        height: j['height'] ?? '',
        year: j['year'] ?? '',
        ppg: (j['ppg'] ?? 0).toDouble(),
        rpg: (j['rpg'] ?? 0).toDouble(),
        apg: (j['apg'] ?? 0).toDouble(),
        weightLbs: j['weightLbs'],
      );
}

class GameItem {
  final DateTime date;
  final String opponent, status;
  final bool home;

  GameItem({
    required this.date,
    required this.opponent,
    required this.home,
    required this.status,
  });

  factory GameItem.fromJson(Map<String, dynamic> j) => GameItem(
        date: DateTime.parse(j['date']),
        opponent: j['opponent'],
        home: j['home'],
        status: j['status'],
      );
}

class School {
  final String id, name, conference, city, primaryColor, secondaryColor, logo;
  final List<Player> roster;
  final List<GameItem> schedule;

  School({
    required this.id,
    required this.name,
    required this.conference,
    required this.city,
    required this.primaryColor,
    required this.secondaryColor,
    required this.logo,
    required this.roster,
    required this.schedule,
  });

  factory School.fromJson(Map<String, dynamic> j) => School(
        id: j['id'],
        name: j['name'],
        conference: j['conference'],
        city: j['city'],
        primaryColor: j['primaryColor'],
        secondaryColor: j['secondaryColor'],
        logo: j['logo'],
        roster: (j['roster'] as List).map((p) => Player.fromJson(p)).toList(),
        schedule:
            (j['schedule'] as List).map((g) => GameItem.fromJson(g)).toList(),
      );
}

/// ===============================================================
/// DATA LOADER
/// ===============================================================
class NCData {
  final String state;
  final List<School> schools;
  NCData({required this.state, required this.schools});
}

class NCLoader {
  static Future<NCData> load() async {
    final raw = await rootBundle.loadString('assets/data/nc_d1.json');
    final j = json.decode(raw) as Map<String, dynamic>;
    final schools =
        (j['schools'] as List).map((s) => School.fromJson(s)).toList();
    return NCData(state: j['state'], schools: schools);
  }
}

/// ===============================================================
/// APP SHELL
/// ===============================================================
void main() {
  runApp(const SportslyticsApp());
}

class SportslyticsApp extends StatelessWidget {
  const SportslyticsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sportslytics',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1E88E5)),
      ),
      home: const _RootShell(),
    );
  }
}

class _RootShell extends StatefulWidget {
  const _RootShell({super.key});
  @override
  State<_RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<_RootShell> {
  int _index = 0;

  final _pages = const [
    TodayScreen(),
    TeamsScreen(),
    FavoritesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sportslytics')),
      body: _pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.today), label: 'Today'),
          NavigationDestination(icon: Icon(Icons.groups), label: 'Teams'),
          NavigationDestination(icon: Icon(Icons.star), label: 'Favorites'),
        ],
      ),
    );
  }
}

/// ===============================================================
/// TODAY TAB  — lists all scheduled games from JSON
/// ===============================================================
class TodayScreen extends StatefulWidget {
  const TodayScreen({super.key});
  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  late Future<List<_GameRow>> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadGames();
  }

  Future<List<_GameRow>> _loadGames() async {
    final data = await NCLoader.load();
    final games = <_GameRow>[];
    for (final s in data.schools) {
      for (final g in s.schedule) {
        games.add(_GameRow(
          school: s.name,
          opponent: g.opponent,
          home: g.home,
          date: g.date,
          status: g.status,
        ));
      }
    }
    games.sort((a, b) => a.date.compareTo(b.date));
    return games;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<_GameRow>>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        final games = snap.data ?? [];
        if (games.isEmpty) {
          return const Center(child: Text('No upcoming games.'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: games.length,
          itemBuilder: (_, i) {
            final g = games[i];
            final vs = g.home
                ? '${g.opponent} @ ${g.school}'
                : '${g.school} @ ${g.opponent}';
            final date = '${g.date.month}/${g.date.day}/${g.date.year}';
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: const Icon(Icons.event),
                title: Text(vs),
                subtitle: Text('${g.status} • $date'),
              ),
            );
          },
        );
      },
    );
  }
}

class _GameRow {
  final String school, opponent, status;
  final DateTime date;
  final bool home;
  _GameRow({
    required this.school,
    required this.opponent,
    required this.home,
    required this.date,
    required this.status,
  });
}

/// ===============================================================
/// TEAMS TAB  — grid of schools, tap to open details
/// ===============================================================
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
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.2,
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
                      Text(
                        t.name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w600),
                      ),
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

/// ===============================================================
/// SCHOOL DETAIL  — roster + schedule; tap player for details
/// ===============================================================
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
                subtitle: Text('${p.pos} • #${p.number} • ${p.year} • ${p.height}'
                    '${p.weightLbs != null ? ' • ${p.weightLbs} lbs' : ''}'),
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

/// ===============================================================
/// PLAYER DETAIL
/// ===============================================================
class PlayerDetailScreen extends StatelessWidget {
  final Player player;
  final School school;
  const PlayerDetailScreen({super.key, required this.player, required this.school});

  @override
  Widget build(BuildContext context) {
    final weightText = player.weightLbs != null ? ' • ${player.weightLbs} lbs' : '';
    return Scaffold(
      appBar: AppBar(title: Text(player.name)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          '${player.name}\n'
          'School: ${school.name}\n'
          'Position: ${player.pos}\n'
          'Jersey: #${player.number}\n'
          'Height: ${player.height}$weightText\n'
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

/// ===============================================================
/// FAVORITES (placeholder)
/// ===============================================================
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('No favorites yet. Tap ⭐ on teams to add.'),
    );
  }
}
