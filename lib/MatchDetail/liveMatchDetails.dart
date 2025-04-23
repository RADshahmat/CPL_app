import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class LiveMatchDetailsPage extends StatefulWidget {
  final Map<String, dynamic> liveMatchData;
  final String teamA;
  final String teamB;
  final IO.Socket socket;

  LiveMatchDetailsPage(this.liveMatchData, this.teamA, this.teamB, this.socket);

  @override
  _LiveMatchDetailsPageState createState() => _LiveMatchDetailsPageState();
}

class _LiveMatchDetailsPageState extends State<LiveMatchDetailsPage> {
  Map<String, dynamic> firstInningScore = {};
  Map<String, dynamic> secondInningScore = {};
  List<dynamic> strikerNonstrikerbowler = [];
  List<dynamic> teamASquad = [];
  List<dynamic> teamBSquad = [];
  late double screenWidth;
  late Timer _timer;
  //late Timer _scoreTimer;
  bool _isLiveVisible = true;
  bool isLoading = true;
  late IO.Socket socket;

  @override
  void initState() {
    super.initState();
    fetchScores();
    fetchSquads();
    //_initializeSocket();
    _startTimer();
    widget.socket.on('fetchScores', (_) {
    if (mounted) {
      fetchScores();
      fetchSquads();
    }
  });
  }

  @override
  void dispose() {
    _timer.cancel();
    // _scoreTimer.cancel();
    //socket.disconnect();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(milliseconds: 500), (timer) {
      setState(() {
        _isLiveVisible = !_isLiveVisible;
      });
    });
  }

  Future<void> fetchScores() async {
    await fetchFirstInningScore();
    await fetchSecondInningScore();

    setState(() {
      isLoading = false;
    });
  }

  Future<void> fetchFirstInningScore() async {
    final scoreResponse = await http.get(Uri.parse(
        'http://93.127.166.229:8080/rest_apis/first_inn_score.php?match_id=${widget.liveMatchData['fix_id']}'));
    if (scoreResponse.statusCode == 200) {
      setState(() {
        firstInningScore = json.decode(scoreResponse.body)[0];
        ////print('hiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii ${widget.teamA}');
      });
    } else {
      throw Exception('Failed to load first inning score');
    }
  }

  Future<void> fetchSecondInningScore() async {
    final scoreResponse = await http.get(Uri.parse(
        'http://93.127.166.229:8080/rest_apis/second_inn_score.php?match_id=${widget.liveMatchData['fix_id']}'));
    if (scoreResponse.statusCode == 200) {
      setState(() {
        secondInningScore = json.decode(scoreResponse.body)[0];
      });
      ////print("bbbbbb");
    } else {
      throw Exception('Failed to load second inning score');
    }
  }

  Future<void> fetchSquads() async {
    final squadResponse = await http.get(Uri.parse(
        'http://93.127.166.229:8080/rest_apis/liveMatchScreenSquad.php?match_id=${widget.liveMatchData['fix_id']}&teamA=${widget.teamA}&teamB=${widget.teamB}'));
    if (squadResponse.statusCode == 200) {
      final data = json.decode(squadResponse.body);
      ////print('this is data vai kam kor $data');
      setState(() {
        teamASquad = data['teamA_squad'];
        teamBSquad = data['teamB_squad'];
      });
    } else {
      throw Exception('Failed to load squads');
    }
  }

  String convertBallsToOvers(String balls) {
    int totalBalls = int.parse(balls);
    int overs = totalBalls ~/ 6;
    int ballsRemaining = totalBalls % 6;
    return '$overs.$ballsRemaining';
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Color.fromARGB(0xFF, 0x2B, 0x2D, 0x33),
      appBar: AppBar(
        backgroundColor: Colors.indigo.withOpacity(.03),
        title: Text(
          'Live Match Details',
          style: TextStyle(color: Colors.white, fontSize: 25),
        ),
        iconTheme:
            IconThemeData(color: const Color.fromARGB(255, 255, 255, 255)),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshPosts,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                backgroundColor: Colors.indigo.withOpacity(.03),
                expandedHeight: 252.0,
                flexibleSpace: FlexibleSpaceBar(
                  background: widget.liveMatchData.isEmpty
                      ? Center(
                          child: Container(
                            width: 100,
                            height: 100,
                            child: Center(
                              child: LoadingIndicator(
                                indicatorType: Indicator.ballGridPulse,
                                colors: const [Colors.white],
                                strokeWidth: 1,
                                pathBackgroundColor:
                                    Color.fromRGBO(44, 62, 80, 1),
                              ),
                            ),
                          ),
                        )
                      : Column(
                          children: [
                            Container(
                              height: 250,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: 1,
                                itemBuilder: (BuildContext context, int index) {
                                  return _buildLiveMatchCard();
                                },
                              ),
                            ),
                          ],
                        ),
                ),
                automaticallyImplyLeading: false,
              ),
            ];
          },
          body: isLoading
              ? Center(child: CircularProgressIndicator())
              : _buildTabView(context),
        ),
      ),
    );
  }

  Widget _buildLiveMatchCard() {
    String tossWinner = widget.liveMatchData['toss_team_name'] ?? 'toss team';
    String selectedAction = widget.liveMatchData['selected'] ?? 'ki re';
    String formattedDate =
        widget.liveMatchData['match_formatted_date'] ?? 'kire1';
    String formattedTime =
        widget.liveMatchData['match_formatted_time'] ?? 'kire2';
    String matchType = widget.liveMatchData['match_type'] ?? 'kire3';
    int match_balls = widget.liveMatchData['match_balls'] ?? 'kire4';
    String secondInningRunsString = secondInningScore['runs'] ?? '0';
    String firstInningRunsString = firstInningScore['runs'] ?? '0';
    String secondInningballString = secondInningScore['bowls'] ?? '0';
    String secondInningWicketString = secondInningScore['wickets'] ?? '0';

    bool isFirstInningScoreNull = firstInningScore.isEmpty;
    bool isSecondInningScoreNull = secondInningScore.isEmpty;

    bool isFirstInningCompleted = firstInningScore['status'] == '1';

    int secondInningRuns = int.tryParse(secondInningRunsString) ?? 0;
    int firstInningRuns = int.tryParse(firstInningRunsString) ?? 0;
    int secondInningWickets = int.tryParse(secondInningWicketString) ?? 0;

    int wicketRemain = 10 - secondInningWickets;
    int runsNeed = (firstInningRuns - secondInningRuns) + 1;

    int secondInningBalls = int.tryParse(secondInningballString) ?? 0;
    int ballsRemain = (match_balls - secondInningBalls);

    return Container(
      margin: EdgeInsets.all(16),
      width: screenWidth - 30,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color.fromARGB(255, 21, 146, 155),
            Color.fromARGB(255, 12, 100, 120)
          ],
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 10,
            left: 10,
            child: Text(
              '$formattedDate  $formattedTime  $matchType',
              style: TextStyle(color: Colors.white),
            ),
          ),
          Positioned(
            top: 7,
            right: 10,
            child: AnimatedOpacity(
              duration: Duration(milliseconds: 500),
              opacity: _isLiveVisible ? 1.0 : 0.0, // Toggle opacity
              child: Container(
                padding: EdgeInsets.all(5.0),
                decoration: BoxDecoration(
                  color: Color.fromARGB(
                      255, 240, 71, 113), // Set background color to red
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  'Live',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 22),
                isFirstInningScoreNull || isSecondInningScoreNull
                    ? CircularProgressIndicator()
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  '${firstInningScore['batting_team_name']}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.network(
                                      '${firstInningScore['batting_team_logo']}',
                                      height: 50,
                                      width: 50,
                                    ),
                                    SizedBox(width: 10),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${firstInningScore['runs']}/${firstInningScore['wickets']}',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: 5),
                                        Text(
                                          '(${convertBallsToOvers(firstInningScore['bowls'])})',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),
                              ],
                            ),
                          ),
                          Text(
                            'VS',
                            style: TextStyle(
                              color: Colors.yellow,
                              fontSize: 20.0,
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  '${secondInningScore['batting_team_name']}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          isFirstInningCompleted
                                              ? 'Yet to'
                                              : '${secondInningScore['runs']}/${secondInningScore['wickets']}',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: 5),
                                        Text(
                                          isFirstInningCompleted
                                              ? 'Bat'
                                              : '(${convertBallsToOvers(secondInningScore['bowls'])})',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ],
                                    ),
                                    SizedBox(width: 10),
                                    Image.network(
                                      '${secondInningScore['batting_team_logo']}',
                                      height: 50,
                                      width: 50,
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),
                              ],
                            ),
                          ),
                        ],
                      ),
                SizedBox(height: 10),
                if (isFirstInningCompleted ||
                    secondInningScore['batting_team_name'] == null ||
                    firstInningScore['batting_team_name'] == null) ...[
                  Text(
                    '$tossWinner won the toss and elected to $selectedAction first',
                    style: TextStyle(color: Colors.white),
                  ),
                ] else ...[
                  if (runsNeed > 0 &&
                      (ballsRemain != 0 && wicketRemain != 0)) ...[
                    Text(
                      '${secondInningScore['batting_team_name']} Need $runsNeed runs from $ballsRemain balls',
                      style: TextStyle(color: Colors.white),
                    ),
                  ] else if (runsNeed - 1 == 0 &&
                      (ballsRemain == 0 || wicketRemain == 0)) ...[
                    Text(
                      'Match Drawn',
                      style: TextStyle(color: Colors.white),
                    ),
                  ] else if (runsNeed <= 0) ...[
                    Text(
                        '${secondInningScore['batting_team_name']} won by $wicketRemain wickets',
                        style: TextStyle(color: Colors.white))
                  ] else if (runsNeed > 0 &&
                      (ballsRemain == 0 || wicketRemain == 0)) ...[
                    Text(
                      '${firstInningScore['batting_team_name']} won the match by ${runsNeed - 1} runs ',
                      style: TextStyle(color: Colors.white),
                    ),
                  ]
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabView(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Color.fromARGB(0xFF, 0x2B, 0x2D, 0x33),
        appBar: AppBar(
          backgroundColor: Color.fromARGB(0xFF, 0x2B, 0x2D, 0x33),
          automaticallyImplyLeading: false,
          leadingWidth: MediaQuery.of(context).size.width,
          leading: TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            tabs: [
              Tab(text: firstInningScore['batting_team_name'] ?? ''),
              Tab(text: secondInningScore['batting_team_name'] ?? ''),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildPlayerListView(teamASquad),
            _buildPlayerListView(teamBSquad),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerListView(List<dynamic> players) {
    if (players.isEmpty) {
      return Center(
        child: Text(
          'No players available',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    // Sort the players based on the status
    players.sort((a, b) {
      // Check if `a` or `b` has status 1, 2, or 3
      bool isAImportant =
          a['status'] == '1' || a['status'] == '2' || a['status'] == '3';
      bool isBImportant =
          b['status'] == '1' || b['status'] == '2' || b['status'] == '3';

      if (isAImportant && !isBImportant) {
        return -1; // a comes before b
      } else if (!isAImportant && isBImportant) {
        return 1; // b comes before a
      } else {
        return 0; // maintain the order for non-important players
      }
    });

    return ListView.builder(
      itemCount: players.length,
      itemBuilder: (context, index) {
        final player = players[index];

        // Determine the background color based on the player's status
        Color cardColor = Colors.transparent;

        if (player['status'] == '1' || player['status'] == '2') {
          cardColor = Color.fromARGB(
              255, 12, 100, 120); // Set to green for status 1 or 2
        } else if (player['status'] == '3') {
          cardColor =
              Color.fromARGB(255, 220, 88, 110); // Set to red for status 3
        }

        return Container(
          child: Card(
            color: cardColor,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(player['player_image'] ?? ''),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              player['status'] == '1'
                                  ? '${player['name']}'
                                  : (player['status'] == '3'
                                      ? '${player['name']}  '
                                      : (player['name'] ?? '')),
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(width: 10),
                            Text(
                              player['taken_by'] == "N/A"
                                  ? ''
                                  : (player['taken_by']),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: const Color.fromARGB(255, 223, 63, 63),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (player['status'] == '1')
                              SizedBox(
                                width: 10,
                              ),
                            if (player['status'] == '1')
                              Image.asset(
                                'assets/images/batsman.png',
                                width: 20,
                                height: 20,
                              ),
                            if (player['status'] == '3')
                              Image.asset(
                                'assets/images/bowler.png',
                                width: 20,
                                height: 20,
                              ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildPlayerInfo('Runs', player['runs'] ?? '0'),
                            _buildPlayerInfo(
                                'Balls', player['balls_played'] ?? '0'),
                            Container(
                                height: 40,
                                width: 1,
                                color: Color.fromARGB(255, 255, 255, 255)),
                            _buildPlayerInfo(
                                'Given', player['runs_given'] ?? '0'),
                            _buildPlayerInfo(
                                'Overs',
                                convertBallsToOvers(
                                    player['overs_bowled'] ?? '0')),
                            _buildPlayerInfo(
                                'Wickets', player['wickets'] ?? '0'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlayerInfo(String label, String? value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        SizedBox(height: 4),
        Text(
          value ?? '',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Future<void> _refreshPosts() async {
    fetchScores();
    fetchSquads();
  }
}
