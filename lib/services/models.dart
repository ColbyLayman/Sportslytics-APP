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
        weightLbs: j['weightLbs'], // optional in JSON
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
