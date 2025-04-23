import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async'; // Import for Timer
import 'package:carousel_slider/carousel_slider.dart';
import 'about.dart';
import 'fixtures/fixture.dart';
import 'pointstable.dart';
import 'Teams/teams.dart';
import 'Players/topplayers.dart';
import 'Matches/history.dart';
import 'MatchDetail/liveMatchDetails.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;


class CustomNavigatorObserver extends NavigatorObserver {
  final VoidCallback onScreenResumed;

  CustomNavigatorObserver({required this.onScreenResumed});

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);

    // Trigger callback when navigating back to this route
    if (previousRoute?.settings.name == '/CricketDashBoard') {
      onScreenResumed();
    }
  }
}


class PCDashBoardScreen extends StatefulWidget {
  static String tag = '/CricketDashBoard';

  @override
  _PCDashBoardScreenState createState() => _PCDashBoardScreenState();
}

class _PCDashBoardScreenState extends State<PCDashBoardScreen> {
  List<dynamic> fixtures = [];
  Map<String, dynamic> liveMatchData = {};
  Map<String, dynamic> firstInningScore = {};
  Map<String, dynamic> secondInningScore = {};
  List<dynamic> strikerNonstrikerbowler = [];
  late IO.Socket socket;

  List<Post> posts = [];
  late double screenWidth;
  late Timer _timer;
  //late Timer _scoreTimer;
  bool _isLiveVisible = true;
  String isExpanded = '';
  bool _isLoading = false;
  int _currentPage = 0;
  final int _pageSize = 5;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    //print("init State Ghus Gaya");
    fetchFixtures();
    fetchLiveMatchData();
    fetchPosts(isRefresh: false);
    _startTimer();
    _initializeSocket();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        fetchPosts(isRefresh: false); // Fetch more posts on scroll
      }
    });
  }



  @override
  void dispose() {
    _timer.cancel();
    //_scoreTimer.cancel();
    //socket.disconnect();
    _scrollController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(milliseconds: 500), (timer) {
      setState(() {
        _isLiveVisible = !_isLiveVisible;
      });
    });
  }

  void _initializeSocket() {
    ////print('Attempting to connect to the socket...');
    socket = IO.io('https://node-eld6.onrender.com', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });

    socket.onConnect((_) {
      //print('Socket connected ppp');
    });

    socket.on('fetchScores', (_) {
      ////print('Score update signal received');
      fetchLiveMatchData();
      fetchFixtures();
    });

    socket.onDisconnect((_) {
      //print('Socket disconnected ppp');
    });

    socket.onConnectError((data) {
      ////print('Connection Error: $data');
    });

    socket.onError((data) {
      ////print('Error: $data');
    });
  }

  Future<void> fetchFixtures() async {
    final response = await http.get(
        Uri.parse('http://93.127.166.229:8080/rest_apis/upcoming_matches.php'));
    if (response.statusCode == 200) {
      setState(() {
        fixtures = json.decode(response.body);
        ////print('fixture $fixtures');
      });
    } else {
      throw Exception('Failed to load fixtures');
    }
  }

  Future<void> fetchLiveMatchData() async {
    final liveMatchResponse = await http.get(
        Uri.parse('http://93.127.166.229:8080/rest_apis/toss_n_live_team.php'));
    if (liveMatchResponse.statusCode == 200) {
      setState(() {
        if (json.decode(liveMatchResponse.body).isNotEmpty) {
          liveMatchData = json.decode(liveMatchResponse.body)[0];
          // Fetch scores and striker/non-striker data
          fetchFirstInningScore();
          fetchSecondInningScore();
          fetchStrikerNonstrikerBowler();
        } else {
          // Clear data if no live match
          liveMatchData = {};
          firstInningScore = {};
          secondInningScore = {};
          strikerNonstrikerbowler = [];
        }
        ////print('toss $liveMatchData');
      });
    } else {
      throw Exception('Failed to load live match data');
    }
  }

  Future<void> fetchFirstInningScore() async {
    final scoreResponse = await http.get(Uri.parse(
        'http://93.127.166.229:8080/rest_apis/first_inn_score.php?match_id=${liveMatchData['fix_id']}'));
    if (scoreResponse.statusCode == 200) {
      setState(() {
        firstInningScore = json.decode(scoreResponse.body)[0];
        ////print('first innings $firstInningScore');
      });
    } else {
      throw Exception('Failed to load first inning score');
    }
  }

  Future<void> fetchSecondInningScore() async {
    if (liveMatchData.isNotEmpty) {
      final scoreResponse = await http.get(Uri.parse(
          'http://93.127.166.229:8080/rest_apis/second_inn_score.php?match_id=${liveMatchData['fix_id']}'));
      if (scoreResponse.statusCode == 200) {
        setState(() {
          secondInningScore = json.decode(scoreResponse.body)[0];
          ////print('second innings $secondInningScore');
        });
      } else {
        throw Exception('Failed to load second inning score');
      }
    }
  }

  Future<void> fetchStrikerNonstrikerBowler() async {
    if (liveMatchData.isNotEmpty) {
      final scoreResponse = await http.get(Uri.parse(
          'http://93.127.166.229:8080/rest_apis/get_striker_nonstriker_bowler.php?match_id=${liveMatchData['fix_id']}'));
      if (scoreResponse.statusCode == 200) {
        setState(() {
          strikerNonstrikerbowler = json.decode(scoreResponse.body);
          ////print('$strikerNonstrikerbowler');
        });
      } else {
        throw Exception('Failed to load Striker Non Striker and Bowler');
      }
    }
  }

  Future<void> fetchPosts({required bool isRefresh}) async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });
    ////print(_isLoading);
    final offset = isRefresh ? 0 : _currentPage * _pageSize;
    final url = Uri.parse(
        'http://93.127.166.229:8080/rest_apis/get_posts.php?limit=$_pageSize&offset=$offset');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> fetchedData = json.decode(response.body);
        final List<Post> posts =
            fetchedData.map((data) => Post.fromJson(data)).toList();

        setState(() {
          if (isRefresh) {
            this.posts = posts; // Replace existing data
            _currentPage = 1;
          } else {
            this.posts.addAll(posts); // Append to the existing list
            _currentPage++;
          }
        });
      } else {
        ////print('Failed to fetch posts: ${response.statusCode}');
      }
    } catch (e) {
      ////print('Error fetching posts: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshPosts() async {
    ////print("dhoke");
    fetchPosts(isRefresh: true);
    fetchFirstInningScore();
    fetchSecondInningScore();
    fetchStrikerNonstrikerBowler();
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
    return  Scaffold(
      //backgroundColor: Colors.indigo.withOpacity(.20),
      backgroundColor: Color.fromARGB(255, 2, 30, 39),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 10, 101, 104),
        title: Text(
          'PSTU Cricket Fever',
          style: TextStyle(color: Colors.white, fontSize: 25),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      drawer: Drawer(
        backgroundColor:
            Color.fromRGBO(201, 215, 225, 1.0), // Subtle background color
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Carousel Header
            Container(
              height: 200.0,
              margin: EdgeInsets.only(bottom: 8.0),
              child: CarouselSlider(
                options: CarouselOptions(
                  height: 200.0,
                  enlargeCenterPage: true,
                  autoPlay: true,
                  aspectRatio: MediaQuery.of(context).size.width / 200,
                  viewportFraction: 1,
                ),
                items: _buildSliderItems(),
              ),
            ),
            // Menu Items
            ListTile(
              leading: Icon(Icons.home, color: Colors.blue),
              title: Text(
                'Home',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0)),
              tileColor: const Color.fromARGB(
                  0, 255, 255, 255), // Highlight for selected
              onTap: () {
                Navigator.pop(context);
              },
            ),
            SizedBox(height: 0), // Add spacing between items
            ListTile(
              leading: Icon(Icons.sports_cricket, color: Colors.blue),
              title: Text(
                'Fixtures',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0)),
              tileColor: const Color.fromARGB(0, 255, 255, 255),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Fixture()),
                );
              },
            ),
            SizedBox(height: 0),
            ListTile(
              leading: Icon(Icons.groups, color: Colors.blue),
              title: Text(
                'Teams',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0)),
              tileColor: const Color.fromARGB(0, 255, 255, 255),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TeamsPage()),
                );
              },
            ),
            SizedBox(height: 0),
            ListTile(
              leading: Icon(Icons.table_chart, color: Colors.blue),
              title: Text(
                'Point Table',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0)),
              tileColor: const Color.fromARGB(0, 255, 255, 255),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CricketPointsTablePage()),
                );
              },
            ),
            SizedBox(height: 0),
            ListTile(
              leading: Icon(Icons.leaderboard, color: Colors.blue),
              title: Text(
                'Leaderboard',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0)),
              tileColor: const Color.fromARGB(0, 255, 255, 255),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TopPlayers()),
                );
              },
            ),
            SizedBox(height: 0),
            ListTile(
              leading: Icon(Icons.history, color: Colors.blue),
              title: Text(
                'History',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0)),
              tileColor: const Color.fromARGB(0, 255, 255, 255),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HistoryPage()),
                );
              },
            ),
            SizedBox(height: 0),
            ListTile(
              leading: Icon(Icons.code, color: Colors.blue),
              title: Text(
                'About Developers',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0)),
              tileColor: const Color.fromARGB(0, 255, 255, 255),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AboutDeveloperPage()),
                );
              },
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshPosts,
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Match',
                  style: TextStyle(color: Colors.white, fontSize: 30),
                ),
              ),
              Container(
                height: 250,
                child: fixtures.isEmpty && liveMatchData.isEmpty
                    ? Center(
                        child: _buildEndOfTournamentWidget(),
                      )
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: fixtures.length +
                            (liveMatchData.isNotEmpty ? 1 : 0),
                        itemBuilder: (BuildContext context, int index) {
                          if (liveMatchData.isNotEmpty && index == 0) {
                            return _buildLiveMatchCard();
                          } else {
                            var fixture = fixtures[
                                index - (liveMatchData.isNotEmpty ? 1 : 0)];
                            return _buildFixtureCard(fixture);
                          }
                        },
                      ),
              ),
              SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                primary: false,
                physics: NeverScrollableScrollPhysics(),
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final post = posts[index];
                  return _buildDashboardButton(
                    context,
                    id: post.id.toString(),
                    title: post.title,
                    subject: post.subject,
                    imageUrls: post.images,
                    details: post.details,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildSliderItems() {
    List<Widget> items = [
      'assets/images/slider1.jpg',
      'assets/images/slider2.jpg',
      'assets/images/slider3.jpg',
    ].map((item) {
      return Container(
        width: double.infinity,
        child: Image.asset(
          item,
          fit: BoxFit.cover,
        ),
      );
    }).toList();

    return items;
  }

  Widget _buildLiveMatchCard() {
    String tossWinner = liveMatchData['toss_team_name'];
    String selectedAction = liveMatchData['selected'];
    String formattedDate = liveMatchData['match_formatted_date'];
    String formattedTime = liveMatchData['match_formatted_time'];
    String matchType = liveMatchData['match_type'] ?? 'kisu ekta';
    int match_balls = liveMatchData['match_balls'] ?? 60;
    String secondInningRunsString = secondInningScore['runs'] ?? '';
    String firstInningRunsString = firstInningScore['runs'] ?? '';
    String secondInningballString = secondInningScore['bowls'] ?? '';
    String secondInningWicketString = secondInningScore['wickets'] ?? '';
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
    String strikerName = '';
    String strikerRuns = '';
    String strikerBallsplayed = '';
    String nonStrikerName = '';
    String nonStrikerRuns = '';
    String nonstrikerBallsplayed = '';
    String bowlerName = '';
    String bowlerOversbowled = '';
    String bowlerRunsgiven = '';
    String bowlerWicket = '';

    for (var playerData in strikerNonstrikerbowler) {
      if (playerData['status'] == '1') {
        strikerName = playerData['name'] ?? 'jnc';
        strikerRuns = playerData['runs'] ?? 'sjdcbjhsdbc';
        strikerBallsplayed = playerData['balls_played'] ?? 'jdbcuds';
      } else if (playerData['status'] == '2') {
        nonStrikerName = playerData['name'] ?? 'jbchd';
        nonStrikerRuns = playerData['runs'] ?? 'bcgdc';
        nonstrikerBallsplayed = playerData['balls_played'] ?? 'dhcgjhc';
      } else if (playerData['status'] == '3') {
        bowlerName = playerData['name'] ?? 'jbdkcgvdc';
        bowlerOversbowled = playerData['overs_bowled'] ?? 'dshcvsdgv';
        bowlerRunsgiven = playerData['runs_given'] ?? 'hdgvcrituyg';
        bowlerWicket = playerData['wickets'] ?? 'yytcugydycgsiu';
      }
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => LiveMatchDetailsPage(liveMatchData,
                  firstInningScore['batting'], secondInningScore['batting'],socket,)),
        );
      },
      child: Container(
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
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    isFirstInningCompleted
                                        ? '$strikerName $strikerRuns ($strikerBallsplayed)*\n$nonStrikerName $nonStrikerRuns ($nonstrikerBallsplayed)'
                                        : (() {
                                            try {
                                              return '$bowlerName \n$bowlerWicket - $bowlerRunsgiven - (${convertBallsToOvers(bowlerOversbowled)})';
                                            } catch (e) {
                                              return '-';
                                            }
                                          })(),
                                    style: TextStyle(
                                      color: Color.fromRGBO(252, 250, 250, 1.0),
                                      fontFamily: 'Roboto',
                                      fontSize:
                                          14, 
                                      fontWeight: FontWeight.w400,
                                    ),
                                  )
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
                                            style:
                                                TextStyle(color: Colors.white),
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
                                  Text(
                                    isFirstInningCompleted
                                        ? (() {
                                            try {
                                              return '$bowlerName \n$bowlerWicket - $bowlerRunsgiven - (${convertBallsToOvers(bowlerOversbowled)})';
                                            } catch (e) {
                                              return '-';
                                            }
                                          })()
                                        : '$strikerName $strikerRuns ($strikerBallsplayed)*\n$nonStrikerName $nonStrikerRuns ($nonstrikerBallsplayed)',
                                    style: TextStyle(color: Colors.white),
                                  ),
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
      ),
    );
  }

  Widget _buildFixtureCard(dynamic fixture) {
    return Container(
      margin: EdgeInsets.all(16),
      width: screenWidth - 30,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color.fromARGB(255, 234, 57, 104),
            Color.fromARGB(255, 200, 5, 207)
          ],
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${fixture['match_type']}',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              '${fixture['teamA_name']} vs ${fixture['teamB_name']}',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.network(
                  fixture['teamA_logo'],
                  height: 50,
                  width: 50,
                ),
                SizedBox(width: 20),
                Text(
                  'VS',
                  style: TextStyle(
                    color: Colors.yellow,
                    fontSize: 20.0,
                  ),
                ),
                SizedBox(width: 20),
                Image.network(
                  fixture['teamB_logo'],
                  height: 50,
                  width: 50,
                ),
              ],
            ),
            SizedBox(height: 10),
            Text(
              '${fixture['match_formatted_date']} at ${fixture['match_formatted_time']}',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEndOfTournamentWidget() {
    return Container(
      margin: EdgeInsets.all(16),
      width: screenWidth - 30,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color.fromARGB(255, 234, 57, 104),
            Color.fromARGB(255, 200, 5, 207)
          ],
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          'CSE Premier League PSTU',
          style: TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildDashboardButton(
    BuildContext context, {
    required String id,
    required String subject,
    required List<String> imageUrls,
    required String title,
    required String details,
  }) {
    return StatefulBuilder(
      builder: (context, setState) {
        final String truncatedDetails =
            details.split(RegExp(r'(?<=\s)')).take(22).join(' ');

        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            // Handle your tap logic here
          },
          child: Center(
            child: Container(
              width: MediaQuery.of(context).size.width - 30,
              padding: EdgeInsets.all(16),
              margin: EdgeInsets.all(8),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subject,
                    style: TextStyle(
                      color: const Color.fromARGB(255, 226, 213, 213),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8),

                  // Carousel Slider
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CarouselSlider(
                      options: CarouselOptions(
                        height: 200,
                        enableInfiniteScroll: imageUrls.length > 1,
                        enlargeCenterPage: true,
                        autoPlay: true,
                        autoPlayAnimationDuration: Duration(milliseconds: 800),
                        viewportFraction: 1,
                      ),
                      items: imageUrls.take(5).map((imageUrl) {
                        return Image.network(
                          imageUrl,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        );
                      }).toList(),
                    ),
                  ),
                  SizedBox(height: 12),

                  // Title
                  Text(
                    title,
                    style: TextStyle(
                      color: const Color.fromARGB(255, 255, 255, 255),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),

                  // AnimatedSize for the details text
                  AnimatedSize(
                    duration: Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                    child: Container(
                      child: Text(
                        isExpanded == id ? details : truncatedDetails,
                        style: TextStyle(
                          color: const Color.fromARGB(255, 255, 255, 255)
                              .withOpacity(0.9),
                          fontSize: 16,
                          height: 1.3,
                        ),
                        textAlign: TextAlign.justify,
                      ),
                    ),
                  ),

                  // Show/Hide button if text is truncated
                  if (details.length > truncatedDetails.length)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          isExpanded == id ? isExpanded = '' : isExpanded = id;
                        });
                      },
                      child: Text(
                        isExpanded == id ? "Show Less <<<" : "Show More >",
                        style: TextStyle(
                          color: const Color.fromARGB(255, 255, 255, 255),
                          fontWeight: FontWeight.bold,
                        ),
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
}

class Post {
  final int id;
  final String subject;
  final String title;
  final String image;
  final String details;
  final String createdAt;
  final List<String> images;

  Post({
    required this.id,
    required this.subject,
    required this.title,
    required this.image,
    required this.details,
    required this.createdAt,
    required this.images,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      subject: json['subject'],
      title: json['title'],
      image: json['image'],
      details: json['details'],
      createdAt: json['created_at'],
      images: (json['images'] as String).split(','), // Split images by comma
    );
  }
}
