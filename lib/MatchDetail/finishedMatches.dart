import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:loading_indicator/loading_indicator.dart';

class FinishedMatches extends StatefulWidget {
  final int matchId;
  final int teamA;
  final int teamB;

  FinishedMatches(this.matchId, this.teamA, this.teamB);

  @override
  _FinishedMatchesState createState() => _FinishedMatchesState();
}

class _FinishedMatchesState extends State<FinishedMatches> {
  late double screenWidth;
  dynamic fixture = {};
  List<dynamic> teamA = [];
  List<dynamic> teamB = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchFixtures();
  }

  Future<void> fetchFixtures() async {
    try {
      isLoading = true;
      final response = await http.get(Uri.parse(
          'http://93.127.166.229:8080/rest_apis/finishedMatchScreen.php?match_id=${widget.matchId}&teamA=${widget.teamA}&teamB=${widget.teamB}'));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          fixture = responseData['fixtures'][0];
          teamA = responseData['teamA_squad'];
          teamB = responseData['teamB_squad'];
        });
      } else {
        throw Exception('Failed to load fixtures');
      }
    } catch (error) {
      //print('Error fetching fixtures: $error');
    }
    isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(0xFF, 0x2B, 0x2D, 0x33),
      appBar: AppBar(
        backgroundColor: Colors.indigo.withOpacity(.03),
        title: Text(
          'Match ${widget.matchId} Details',
          style: TextStyle(color: Colors.white, fontSize: 25),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              backgroundColor: Colors.indigo.withOpacity(.03),
              expandedHeight: 252.0,
              flexibleSpace: FlexibleSpaceBar(
                background: isLoading
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
                          _buildFixtureCard(context, fixture),
                          SizedBox(height: 20),
                        ],
                      ),
              ),
              automaticallyImplyLeading: false,
            ),
          ];
        },
        body: isLoading ? Center() : _buildTabView(context),
      ),
    );
  }

  Widget _buildFixtureCard(BuildContext context, dynamic fixture) {
    return Container(
      margin: EdgeInsets.all(16),
      width: MediaQuery.of(context).size.width - 30,
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color.fromARGB(255, 234, 57, 104),
            Color.fromARGB(255, 200, 5, 207),
          ],
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${fixture['teamA_name']} vs ${fixture['teamB_name']}',
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          SizedBox(height: 10),
          Text(
            '${fixture['match_formatted_date']} at ${fixture['match_formatted_time']}',
            style: TextStyle(color: Colors.white),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTeamColumn(
                  fixture['teamA_logo'], fixture['teamA'], fixture, 1),
              SizedBox(width: 20),
              Text(
                'VS',
                style: TextStyle(
                  color: Colors.yellow,
                  fontSize: 20.0,
                ),
              ),
              SizedBox(width: 20),
              _buildTeamColumn(
                  fixture['teamB_logo'], fixture['teamB'], fixture, 2),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTeamColumn(
      String teamLogoUrl, int teamId, dynamic fixture, int det) {
    int? team = int.tryParse(fixture['team_id']);
    //print(team);
    //print(fixture);
    return Column(
      children: [
        Image.network(
          teamLogoUrl,
          height: 50,
          width: 50,
        ),
        SizedBox(height: 8),
        Text(
          det == 1
              ? ('${team == fixture['teamA'] ? fixture['team1_runs'] : fixture['team2_runs']} / ${team == fixture['teamA'] ? fixture['team1_wickets'] : fixture['team2_wickets']}')
              : ('${team == fixture['teamB'] ? fixture['team1_runs'] : fixture['team2_runs']} / ${team == fixture['teamB'] ? fixture['team1_wickets'] : fixture['team2_wickets']}'),
          style: TextStyle(color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildTabView(BuildContext context) {
    // Ensure teamA and teamB are not empty before rendering TabBarView
    if (teamA.isEmpty || teamB.isEmpty) {
      return Center(
        child:
            CircularProgressIndicator(), // Show loading indicator if data is empty
      );
    }

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
              Tab(text: fixture['teamA_name'] ?? ''),
              Tab(text: fixture['teamB_name'] ?? ''),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildPlayerListView(teamA),
            _buildPlayerListView(teamB),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerListView(List<dynamic> players) {
    if (players.isEmpty) {
      return Center(
        child: Text(
            'No players available'), // Show message if no players are found
      );
    }

    return ListView.builder(
      itemCount: players.length,
      itemBuilder: (context, index) {
        final player = players[index];
        //print("theese are finish player");
        //print(player['taken_by']);
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromRGBO(29, 45, 59, 1.0),
                Color.fromRGBO(82, 90, 100, 1.0),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Card(
            color: Colors.transparent,
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
                        Text(
                          player['name'] ?? '',
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
                              ? 'Not Out'
                              : (player['taken_by']),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: player['taken_by'] == "N/A"?const Color.fromARGB(255, 63, 223, 92):const Color.fromARGB(255, 223, 63, 63),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildPlayerInfo('Runs', player['runs']),
                            _buildPlayerInfo('Balls', player['balls_played']),
                            Container(
                              height: 40,
                              width: 1,
                              color: Color.fromARGB(255, 255, 255, 255)
                            ),
                            _buildPlayerInfo('Given', player['runs_given']),
                            _buildPlayerInfo(
                                'Overs', _formatOvers(player['overs_bowled'])),
                            _buildPlayerInfo('Wickets', player['wickets']),
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
          value ?? '', // Display empty string if value is null
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  String _formatOvers(String? overs) {
    if (overs == null) return '';

    final oversValue = int.tryParse(overs) ?? 0.0;
    final oversInt = (oversValue / 6).toInt();
    final balls = ((oversValue % 6)).toInt();

    return '$oversInt.$balls';
  }
}
