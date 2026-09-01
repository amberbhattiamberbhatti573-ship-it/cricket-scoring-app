import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const CricketScoringApp());
}

class CricketScoringApp extends StatelessWidget {
  const CricketScoringApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DashScore Cricket',
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF09111F),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00D4A8),
          brightness: Brightness.dark,
        ),
      ),
      home: const SetupScreen(),
    );
  }
}

// ------------------------------------------------------------
// SETUP SCREEN
// ------------------------------------------------------------

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final teamAController = TextEditingController(text: 'Team A');
  final teamBController = TextEditingController(text: 'Team B');
  final playersAController = TextEditingController(
    text: 'Player A1\nPlayer A2\nPlayer A3\nPlayer A4\nPlayer A5\nPlayer A6',
  );
  final playersBController = TextEditingController(
    text: 'Player B1\nPlayer B2\nPlayer B3\nPlayer B4\nPlayer B5\nPlayer B6',
  );

  int overs = 2;

  @override
  void dispose() {
    teamAController.dispose();
    teamBController.dispose();
    playersAController.dispose();
    playersBController.dispose();
    super.dispose();
  }

  List<String> _playersFromText(String text) {
    return text
        .split(RegExp(r'[\n,]'))
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toSet()
        .toList();
  }

  void _startMatch() {
    final teamA = teamAController.text.trim();
    final teamB = teamBController.text.trim();
    final playersA = _playersFromText(playersAController.text);
    final playersB = _playersFromText(playersBController.text);

    if (teamA.isEmpty ||
        teamB.isEmpty ||
        playersA.length < 2 ||
        playersB.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Enter both team names and at least 2 players for each team.',
          ),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MatchScreen(
          teamA: teamA,
          teamB: teamB,
          playersA: playersA,
          playersB: playersB,
          maxOvers: overs,
        ),
      ),
    );
  }

  Widget _textField(
      String label,
      TextEditingController controller, {
        int maxLines = 1,
      }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: const Color(0xFF131F33),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'DashScore Cricket',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const SizedBox(height: 20),
            const Icon(
              Icons.sports_cricket,
              size: 70,
              color: Color(0xFF00D4A8),
            ),
            const SizedBox(height: 12),
            const Text(
              'Create New Match',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 28),
            _textField('Team 1 name', teamAController),
            const SizedBox(height: 14),
            _textField(
              'Team 1 players',
              playersAController,
              maxLines: 5,
            ),
            const SizedBox(height: 18),
            _textField('Team 2 name', teamBController),
            const SizedBox(height: 14),
            _textField(
              'Team 2 players',
              playersBController,
              maxLines: 5,
            ),
            const SizedBox(height: 18),
            DropdownButtonFormField<int>(
              value: overs,
              decoration: InputDecoration(
                labelText: 'Match format',
                filled: true,
                fillColor: const Color(0xFF131F33),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
              items: const [
                DropdownMenuItem(value: 2, child: Text('2 Overs')),
                DropdownMenuItem(value: 3, child: Text('3 Overs')),
                DropdownMenuItem(value: 4, child: Text('4 Overs')),
                DropdownMenuItem(value: 5, child: Text('5 Overs')),
                DropdownMenuItem(value: 10, child: Text('10 Overs')),
                DropdownMenuItem(value: 20, child: Text('T20')),
              ],
              onChanged: (value) {
                if (value!= null) {
                  setState(() => overs = value);
                }
              },
            ),
            const SizedBox(height: 28),
            SizedBox(
              height: 52,
              child: FilledButton.icon(
                onPressed: _startMatch,
                icon: const Icon(Icons.play_arrow),
                label: const Text(
                  'START MATCH',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------------
// DATA CLASSES
// ------------------------------------------------------------

class BatterStats {
  int runs = 0;
  int balls = 0;
  int fours = 0;
  int sixes = 0;
  bool out = false;

  double get strikeRate {
    if (balls == 0) return 0;
    return runs * 100 / balls;
  }

  Map<String, dynamic> toJson() {
    return {
      'runs': runs,
      'balls': balls,
      'fours': fours,
      'sixes': sixes,
      'out': out,
    };
  }
}

class BowlerStats {
  int runs = 0;
  int balls = 0;
  int wickets = 0;

  double get economy {
    if (balls == 0) return 0;
    return runs / (balls / 6);
  }
}

class InningsData {
  final String battingTeam;
  final String bowlingTeam;
  final List<String> players;

  int runs = 0;
  int wickets = 0;
  int legalBalls = 0;
  bool complete = false;

  final Map<String, BatterStats> batterStats = {};
  final Map<String, BowlerStats> bowlerStats = {};
  final List<String> recentBalls = [];

  InningsData({
    required this.battingTeam,
    required this.bowlingTeam,
    required this.players,
  }) {
    for (final player in players) {
      batterStats[player] = BatterStats();
    }
  }

  String get oversText {
    return '${legalBalls ~/ 6}.${legalBalls % 6}';
  }

  Map<String, dynamic> toJson() {
    return {
      'battingTeam': battingTeam,
      'bowlingTeam': bowlingTeam,
      'runs': runs,
      'wickets': wickets,
      'overs': oversText,
    };
  }
}

// ------------------------------------------------------------
// MATCH SCREEN
// ------------------------------------------------------------

class MatchScreen extends StatefulWidget {
  final String teamA;
  final String teamB;
  final List<String> playersA;
  final List<String> playersB;
  final int maxOvers;

  const MatchScreen({
    super.key,
    required this.teamA,
    required this.teamB,
    required this.playersA,
    required this.playersB,
    required this.maxOvers,
  });

  @override
  State<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen> {
  late InningsData firstInnings;
  late InningsData secondInnings;

  late List<String> battingPlayers;
  late List<String> bowlingPlayers;

  String? striker;
  String? nonStriker;
  String? currentBowler;

  int inningsNumber = 1;
  bool matchFinished = false;
  bool changingBowler = false;

  @override
  void initState() {
    super.initState();

    firstInnings = InningsData(
      battingTeam: widget.teamA,
      bowlingTeam: widget.teamB,
      players: widget.playersA,
    );

    secondInnings = InningsData(
      battingTeam: widget.teamB,
      bowlingTeam: widget.teamA,
      players: widget.playersB,
    );

    battingPlayers = widget.playersA;
    bowlingPlayers = widget.playersB;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _chooseOpeningPlayers();
    });
  }

  InningsData get innings {
    return inningsNumber == 1? firstInnings: secondInnings;
  }

  int get target {
    return firstInnings.runs + 1;
  }

  String? get winner {
    if (!matchFinished) return null;

    if (secondInnings.runs >= target) {
      return secondInnings.battingTeam;
    }

    if (secondInnings.runs == firstInnings.runs) {
      return 'Match Tied';
    }

    return firstInnings.battingTeam;
  }

  String get resultText {
    if (winner == 'Match Tied') {
      return 'Match Tied';
    }

    if (winner == secondInnings.battingTeam) {
      final wicketsRemaining =
          battingPlayers.length - 1 - secondInnings.wickets;
      return '$winner won by $wicketsRemaining wickets';
    }

    final runDifference = firstInnings.runs - secondInnings.runs;
    return '$winner won by $runDifference runs';
  }

  Future<void> _chooseOpeningPlayers() async {
    if (!mounted) return;

    final result = await showDialog<List<String>>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        String? selectedStriker;
        String? selectedNonStriker;
        String? selectedBowler;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            final canContinue = selectedStriker!= null &&
                selectedNonStriker!= null &&
                selectedBowler!= null &&
                selectedStriker!= selectedNonStriker;

            return AlertDialog(
              title: Text(
                inningsNumber == 1
                    ? 'Start First Innings'
                    : 'Start Second Innings',
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Striker',
                      ),
                      items: battingPlayers
                          .map(
                            (player) => DropdownMenuItem(
                          value: player,
                          child: Text(player),
                        ),
                      )
                          .toList(),
                      onChanged: (value) {
                        setDialogState(() => selectedStriker = value);
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Non-striker',
                      ),
                      items: battingPlayers
                          .map(
                            (player) => DropdownMenuItem(
                          value: player,
                          child: Text(player),
                        ),
                      )
                          .toList(),
                      onChanged: (value) {
                        setDialogState(() => selectedNonStriker = value);
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Bowler',
                      ),
                      items: bowlingPlayers
                          .map(
                            (player) => DropdownMenuItem(
                          value: player,
                          child: Text(player),
                        ),
                      )
                          .toList(),
                      onChanged: (value) {
                        setDialogState(() => selectedBowler = value);
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                FilledButton(
                  onPressed: canContinue
                      ? () {
                    Navigator.pop(
                      context,
                      [
                        selectedStriker!,
                        selectedNonStriker!,
                        selectedBowler!,
                      ],
                    );
                  }
                      : null,
                  child: const Text('CONTINUE'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result!= null && mounted) {
      setState(() {
        striker = result[0];
        nonStriker = result[1];
        currentBowler = result[2];
      });
    }
  }

  Future<void> _chooseNewBowler() async {
    final available = bowlingPlayers
        .where((player) => player!= currentBowler)
        .toList();

    if (available.isEmpty) {
      changingBowler = false;
      return;
    }

    final selected = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        String? value;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Over Complete'),
              content: DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Select next bowler',
                ),
                items: available
                    .map(
                      (player) => DropdownMenuItem(
                    value: player,
                    child: Text(player),
                  ),
                )
                    .toList(),
                onChanged: (newValue) {
                  setDialogState(() => value = newValue);
                },
              ),
              actions: [
                FilledButton(
                  onPressed: value == null
                      ? null
                      : () => Navigator.pop(context, value),
                  child: const Text('START OVER'),
                ),
              ],
            );
          },
        );
      },
    );

    if (selected!= null && mounted) {
      setState(() {
        currentBowler = selected;
        changingBowler = false;
      });
    }
  }

  Future<void> _chooseReplacementBatter() async {
    final available = battingPlayers.where((player) {
      final stats = innings.batterStats[player]!;
      return player!= striker &&
          player!= nonStriker &&
          !stats.out;
    }).toList();

    if (available.isEmpty) {
      await _finishInnings();
      return;
    }

    final selected = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        String? value;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Wicket'),
              content: DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Select new batter',
                ),
                items: available
                    .map(
                      (player) => DropdownMenuItem(
                    value: player,
                    child: Text(player),
                  ),
                )
                    .toList(),
                onChanged: (newValue) {
                  setDialogState(() => value = newValue);
                },
              ),
              actions: [
                FilledButton(
                  onPressed: value == null
                      ? null
                      : () => Navigator.pop(context, value),
                  child: const Text('NEW BATTER'),
                ),
              ],
            );
          },
        );
      },
    );

    if (selected!= null && mounted) {
      setState(() {
        striker = selected;
      });
    }
  }

  void _swapBatters() {
    final oldStriker = striker;
    striker = nonStriker;
    nonStriker = oldStriker;
  }

  Future<void> _addRuns(int runs) async {
    if (matchFinished || changingBowler || striker == null || nonStriker == null) {
      return;
    }

    setState(() {
      innings.runs += runs;
      innings.legalBalls++;
      innings.recentBalls.insert(0, '$runs');

      final batter = innings.batterStats[striker!]!;
      final bowler = innings.bowlerStats.putIfAbsent(
        currentBowler!,
        BowlerStats.new,
      );

      batter.runs += runs;
      batter.balls++;

      if (runs == 4) batter.fours++;
      if (runs == 6) batter.sixes++;

      bowler.runs += runs;
      bowler.balls++;

      if (runs % 2 == 1) {
        _swapBatters();
      }
    });

    await _checkEndConditions();
  }

  Future<void> _addWide() async {
    if (matchFinished || changingBowler || currentBowler == null) {
      return;
    }

    setState(() {
      innings.runs++;
      innings.recentBalls.insert(0, 'Wd');

      final bowler = innings.bowlerStats.putIfAbsent(
        currentBowler!,
        BowlerStats.new,
      );
      bowler.runs++;
    });

    await _checkEndConditions();
  }

  Future<void> _addWicket() async {
    if (matchFinished ||
        changingBowler ||
        striker == null ||
        currentBowler == null) {
      return;
    }

    setState(() {
      innings.legalBalls++;
      innings.wickets++;
      innings.recentBalls.insert(0, 'W');

      final batter = innings.batterStats[striker!]!;
      final bowler = innings.bowlerStats.putIfAbsent(
        currentBowler!,
        BowlerStats.new,
      );

      batter.balls++;
      batter.out = true;
      bowler.balls++;
      bowler.wickets++;
    });

    await _checkEndConditions();

    if (!matchFinished && innings.wickets < battingPlayers.length - 1) {
      await _chooseReplacementBatter();
    }
  }

  Future<void> _checkEndConditions() async {
    if (inningsNumber == 2 && secondInnings.runs >= target) {
      await _finishMatch();
      return;
    }

    final maximumBalls = widget.maxOvers * 6;
    final allOut = innings.wickets >= battingPlayers.length - 1;
    final oversFinished = innings.legalBalls >= maximumBalls;

    if (allOut || oversFinished) {
      await _finishInnings();
      return;
    }

    if (innings.legalBalls > 0 && innings.legalBalls % 6 == 0) {
      setState(() {
        changingBowler = true;
        _swapBatters();
      });
      await _chooseNewBowler();
    }
  }

  Future<void> _finishInnings() async {
    if (innings.complete) return;

    setState(() {
      innings.complete = true;
    });

    if (inningsNumber == 1) {
      await Future.delayed(const Duration(milliseconds: 300));

      if (!mounted) return;

      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: const Text('First Innings Complete'),
            content: Text(
              '${firstInnings.battingTeam} scored '
                  '${firstInnings.runs}/${firstInnings.wickets} '
                  'in ${firstInnings.oversText} overs.\n\n'
                  '${secondInnings.battingTeam} needs $target runs to win.',
            ),
            actions: [
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('START SECOND INNINGS'),
              ),
            ],
          );
        },
      );

      if (!mounted) return;

      setState(() {
        inningsNumber = 2;
        battingPlayers = widget.playersB;
        bowlingPlayers = widget.playersA;
        striker = null;
        nonStriker = null;
        currentBowler = null;
        changingBowler = false;
      });

      await _chooseOpeningPlayers();
    } else {
      await _finishMatch();
    }
  }

  Future<void> _finishMatch() async {
    if (matchFinished) return;

    setState(() {
      matchFinished = true;
      firstInnings.complete = true;
      secondInnings.complete = true;
    });

    await _saveMatch();

    if (!mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('MATCH COMPLETE'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.emoji_events,
                color: Colors.amber,
                size: 64,
              ),
              const SizedBox(height: 12),
              Text(
                winner == 'Match Tied'? 'Match Tied': '$winner won',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                resultText,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 17),
              ),
            ],
          ),
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('BACK TO HOME'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveMatch() async {
    final preferences = await SharedPreferences.getInstance();

    final oldMatches = preferences.getStringList('matches')?? <String>[];

    final match = {
      'teamA': widget.teamA,
      'teamB': widget.teamB,
      'overs': widget.maxOvers,
      'firstInnings': firstInnings.toJson(),
      'secondInnings': secondInnings.toJson(),
      'result': resultText,
      'winner': winner,
      'date': DateTime.now().toIso8601String(),
    };

    oldMatches.add(jsonEncode(match));
    await preferences.setStringList('matches', oldMatches);
  }

  Widget _scoreButton(
      String label,
      VoidCallback onPressed, {
        Color? color,
        double width = 68,
      }) {
    return SizedBox(
      width: width,
      height: 42,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color?? const Color(0xFF182943),
          foregroundColor: Colors.white,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _scoreCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF123B4A),
            Color(0xFF172842),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          Text(
            innings.battingTeam,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF00D4A8),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${innings.runs}/${innings.wickets}',
            style: const TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            '${innings.oversText} / ${widget.maxOvers} overs',
            style: const TextStyle(color: Colors.white70),
          ),
          if (inningsNumber == 2)...[
            const SizedBox(height: 8),
            Text(
              'Target: $target',
              style: const TextStyle(
                color: Colors.amber,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _playersCard() {
    final strikerStats =
    striker == null? null: innings.batterStats[striker!];
    final nonStrikerStats =
    nonStriker == null? null: innings.batterStats[nonStriker!];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111D31),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          _playerRow(
            'Striker',
            striker,
            strikerStats,
            const Color(0xFF00D4A8),
          ),
          const Divider(color: Colors.white12),
          _playerRow(
            'Non-striker',
            nonStriker,
            nonStrikerStats,
            Colors.white70,
          ),
          const Divider(color: Colors.white12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Bowler',
                style: TextStyle(color: Colors.white70),
              ),
              Text(
                currentBowler?? '-',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _playerRow(
      String title,
      String? name,
      BatterStats? stats,
      Color titleColor,
      ) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: titleColor)),
              const SizedBox(height: 3),
              Text(
                name?? '-',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        if (stats!= null)
          Text(
            '${stats.runs} (${stats.balls})  SR ${stats.strikeRate.toStringAsFixed(1)}',
            style: const TextStyle(color: Colors.white70),
          ),
      ],
    );
  }

  Widget _statsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111D31),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'BATTING STATISTICS',
            style: TextStyle(
              color: Color(0xFF00D4A8),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          ...innings.batterStats.entries.map(
                (entry) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${entry.key}${entry.value.out? " out": ""}',
                    ),
                  ),
                  Text(
                    '${entry.value.runs} runs  '
                        '${entry.value.balls} balls  '
                        '4s: ${entry.value.fours}  '
                        '6s: ${entry.value.sixes}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'BOWLING STATISTICS',
            style: TextStyle(
              color: Color(0xFF00D4A8),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          if (innings.bowlerStats.isEmpty)
            const Text(
              'No bowling data yet',
              style: TextStyle(color: Colors.white54),
            ),
          ...innings.bowlerStats.entries.map(
                (entry) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(child: Text(entry.key)),
                  Text(
                    '${entry.value.balls ~/ 6}.${entry.value.balls % 6} ov  '
                        '${entry.value.runs} runs  '
                        '${entry.value.wickets} wkts',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.teamA} vs ${widget.teamB}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Match summary',
            onPressed: () {
              showDialog<void>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Match Summary'),
                  content: Text(
                    '${firstInnings.battingTeam}: '
                        '${firstInnings.runs}/${firstInnings.wickets} '
                        '(${firstInnings.oversText})\n\n'
                        '${secondInnings.battingTeam}: '
                        '${secondInnings.runs}/${secondInnings.wickets} '
                        '(${secondInnings.oversText})',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('CLOSE'),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.summarize),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(14),
          children: [
            if (matchFinished)
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.amber),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.emoji_events,
                      color: Colors.amber,
                      size: 42,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      resultText,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.amber,
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            _scoreCard(),
            const SizedBox(height: 14),
            _playersCard(),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF111D31),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                children: [
                  const Text(
                    'SCORING',
                    style: TextStyle(
                      color: Color(0xFF00D4A8),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      _scoreButton(
                        '0',
                            () => _addRuns(0),
                      ),
                      _scoreButton(
                        '1',
                            () => _addRuns(1),
                      ),
                      _scoreButton(
                        '2',
                            () => _addRuns(2),
                      ),
                      _scoreButton(
                        '3',
                            () => _addRuns(3),
                      ),
                      _scoreButton(
                        '4',
                            () => _addRuns(4),
                        color: const Color(0xFF176B61),
                      ),
                      _scoreButton(
                        '6',
                            () => _addRuns(6),
                        color: const Color(0xFF805A16),
                      ),
                      _scoreButton(
                        'WIDE',
                        _addWide,
                        color: const Color(0xFF633B63),
                        width: 78,
                      ),
                      _scoreButton(
                        'WICKET',
                        _addWicket,
                        color: const Color(0xFF8B3030),
                        width: 86,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            if (innings.recentBalls.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF111D31),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    const Text(
                      'Recent: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Expanded(
                      child: Text(
                        innings.recentBalls.take(12).join('  '),
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 14),
            _statsCard(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}