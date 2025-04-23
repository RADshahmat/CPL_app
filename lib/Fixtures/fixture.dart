import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:loading_indicator/loading_indicator.dart';
import '../MatchDetail/finishedMatches.dart';

class Fixture extends StatefulWidget {
  @override
  State<Fixture> createState() => _FixtureState();
}

class _FixtureState extends State<Fixture> {
  List<dynamic> fixtures = [];

  Future<void> fetchFixtureData() async {
    try {
      final response = await http.get(
          Uri.parse('http://93.127.166.229:8080/rest_apis/get_fixtures.php'));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        setState(() {
          fixtures = jsonData['rows1'] + jsonData['rows0'];
        });
        //print(fixtures);
        //print('kaka fixtures');
      } else {
        throw Exception('Failed to load fixture data');
      }
    } catch (error) {
      //print('Error: $error');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchFixtureData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(44, 62, 80, 1),
      appBar: AppBar(
        title: Text(
          'Fixture',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color.fromRGBO(41, 57, 74, 1),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: fixtures.isEmpty
          ? Center(
              child: Container(
                width: 100,
                height: 100,
                child: LoadingIndicator(
                  indicatorType: Indicator.ballGridPulse,
                  colors: const [Color.fromARGB(255, 255, 255, 255)],
                  strokeWidth: 1,
                  backgroundColor: Color.fromRGBO(44, 62, 80, 1),
                  pathBackgroundColor: Color.fromRGBO(44, 62, 80, 1),
                ),
              ),
            )
          : ListView.builder(
              itemCount: fixtures.length,
              itemBuilder: (context, index) {
                final fixture = fixtures[index];

                if (fixture['match_finish_flag'] == 10) {
                  return _buildFinishedFixtureCard(fixture);
                } else {
                  return _buildUnfinishedFixtureCard(fixture);
                }
              },
            ),
    );
  }

  Widget _buildFinishedFixtureCard(Map<String, dynamic> fixture) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => FinishedMatches(
                  fixture['fix_id'], fixture['teamA'], fixture['teamB'])),
        );
      },
      child: Card(
        color: Colors.transparent,
        margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildDateTimeRow(
                fixture['match_formatted_date'],
                fixture['match_formatted_time'],
                fixture['match_type'],
              ),
              _buildTeamRow(
                fixture['teamA_name'],
                fixture['teamA_logo'],
                fixture['teamB_name'],
                fixture['teamB_logo'],
              ),
              _status(
                fixture['teamA_name'],
                fixture['teamB_name'],
                fixture['teamA'],
                fixture['teamB'],
                fixture['team_id'],
                fixture['team1_runs'],
                fixture['team1_wickets'],
                fixture['team2_runs'],
                fixture['team2_wickets'],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUnfinishedFixtureCard(Map<String, dynamic> fixture) {
    return Card(
      color: Colors.transparent,
      margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildDateTimeRow(
              fixture['match_formatted_date'],
              fixture['match_formatted_time'],
              fixture['match_type'],
            ),
            _buildTeamRow(
              fixture['teamA_name'],
              fixture['teamA_logo'],
              fixture['teamB_name'],
              fixture['teamB_logo'],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateTimeRow(
      String formattedDate, String formattedTime, String matchType) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromRGBO(107, 110, 117, 1.0),
            Color.fromRGBO(83, 120, 121, 1.0),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              formattedDate,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.0,
              ),
            ),
            Text(
              matchType,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.0,
              ),
            ),
            Text(
              formattedTime,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamRow(
    String teamAName,
    String teamALogoUrl,
    String teamBName,
    String teamBLogoUrl,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromRGBO(82, 87, 93, 1.0),
            Color.fromRGBO(47, 70, 96, 1.0),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: <Widget>[
                Image.network(
                  teamALogoUrl,
                  width: 30,
                  height: 30,
                ),
                SizedBox(width: 10),
                Text(
                  teamAName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                  ),
                ),
              ],
            ),
            // VS
            Text(
              'VS',
              style: TextStyle(
                color: Colors.yellow,
                fontSize: 20.0,
              ),
            ),

            Row(
              children: <Widget>[
                Text(
                  teamBName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                  ),
                ),
                SizedBox(width: 10),
                Image.network(
                  teamBLogoUrl,
                  width: 30,
                  height: 30,
                ),
              ],
            ),
            Row(
              children: <Widget>[],
            )
          ],
        ),
      ),
    );
  }

  Widget _status(
    String teamA,
    String teamB,
    int teamAid,
    int teamBid,
    String teamId,
    String team1Runs,
    String team1Wickets,
    String team2Runs,
    String team2Wickets,
  ) {
    int runs1 = int.tryParse(team1Runs) ?? 0;
    int wickets1 = int.tryParse(team1Wickets) ?? 0;
    int runs2 = int.tryParse(team2Runs) ?? 0;
    int wickets2 = int.tryParse(team2Wickets) ?? 0;

    //print('Tukhor kaka :  $teamAid,$teamBid,$teamId');

    bool isTeamAHome = teamAid == int.tryParse(teamId);

    String result;
    if (isTeamAHome) {
      if (runs1 > runs2) {
        result = '$teamA won by ${runs1 - runs2} runs';
      } else if (runs1 < runs2) {
        result = '$teamB won by ${10 - wickets2} Wickets';
      } else {
        result = 'Match tied';
      }
    } else {
      if (runs1 > runs2) {
        result = '$teamB won by ${runs1 - runs2} runs';
      } else if (runs1 < runs2) {
        result = '$teamA won by ${10 - wickets1} wickets';
      } else {
        result = 'Match tied';
      }
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromRGBO(48, 101, 82, 1.0),
            Color.fromRGBO(26, 55, 63, 1.0),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(10),
          bottomRight: Radius.circular(10),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              result,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
