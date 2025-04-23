import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:loading_indicator/loading_indicator.dart';
import '../Players/playerprofile.dart';

class TopPlayers extends StatefulWidget {
  const TopPlayers({Key? key}) : super(key: key);

  @override
  _TopPlayersState createState() => _TopPlayersState();
}

class _TopPlayersState extends State<TopPlayers> {
  final List<String> batsmenName = [];
  final List<String> batsmenImage = [];
  final List<String> batsmenType = [];
  final List<String> batsmenId = [];
  final List<int> batsmenRuns = [];

  final List<String> bowlersName = [];
  final List<String> bowlersImage = [];
  final List<String> bowlersType = [];
  final List<String> bowlersId = [];
  final List<int> bowlersWickets = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTeamPlayersFromServer();
  }

  Future<void> fetchTeamPlayersFromServer() async {
    var batsmenUrl = 'http://93.127.166.229:8080/rest_apis/top_batsman.php';
    var bowlersUrl = 'http://93.127.166.229:8080/rest_apis/top_bowler.php';

    try {
      // Fetch top batsmen data
      http.Response batsmenResponse = await http.get(Uri.parse(batsmenUrl));
      if (batsmenResponse.statusCode == 200) {
        var batsmenData = jsonDecode(batsmenResponse.body);
        setState(() {
          for (var item in batsmenData) {
            if (item.containsKey('name')) {
              batsmenName.add(item['name']);
            }
            if (item.containsKey('player_image')) {
              batsmenImage.add(item['player_image']);
            }
            if (item.containsKey('player_type')) {
              batsmenType.add(item['player_type']);
            }
            if (item.containsKey('ID')) {
              batsmenId.add(item['ID']);
            }
            if (item.containsKey('runs')) {
              batsmenRuns.add(int.parse(item['runs']));
            }
          }
        });
      } else {
        //print('Failed to fetch top batsmen data');
      }

      // Fetch top bowlers data
      http.Response bowlersResponse = await http.get(Uri.parse(bowlersUrl));
      if (bowlersResponse.statusCode == 200) {
        var bowlersData = jsonDecode(bowlersResponse.body);
        setState(() {
          for (var item in bowlersData) {
            if (item.containsKey('name')) {
              bowlersName.add(item['name']);
            }
            if (item.containsKey('player_image')) {
              bowlersImage.add(item['player_image']);
            }
            if (item.containsKey('player_type')) {
              bowlersType.add(item['player_type']);
            }
            if (item.containsKey('ID')) {
              bowlersId.add(item['ID']);
            }
            if (item.containsKey('wickets')) {
              bowlersWickets.add(int.parse(item['wickets']));
            }
          }
          isLoading = false;
        });
      } else {
        //print('Failed to fetch top bowlers data');
      }
    } catch (error) {
      //print('Error fetching data: $error');
    }
  }

  Widget getPlayerTypeLogo(String playerType) {
    switch (playerType.toLowerCase()) {
      case 'all-rounder':
        return SizedBox(
          width: 20,
          height: 20,
          child: Image.asset('assets/images/all_rounder.png'),
        );
      case 'batsman':
        return SizedBox(
          width: 20,
          height: 20,
          child: Image.asset('assets/images/batsman.png'),
        );
      case 'bowler' || 'bowller':
        return SizedBox(
          width: 20,
          height: 20,
          child: Image.asset('assets/images/bowler.png'),
        );
      case 'wicketkeeper':
        return SizedBox(
          width: 20,
          height: 20,
          child: Image.asset('assets/images/wk.png'),
        );
      default:
        return SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    //print('Fetching player data...');
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Color.fromRGBO(44, 62, 80, 1),
        appBar: AppBar(
          backgroundColor: Color.fromRGBO(34, 49, 63, 1),
          title: Text(
            'Top Players',
            style: TextStyle(color: Colors.white),
          ),
          iconTheme: IconThemeData(color: Colors.white),
          bottom: TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            tabs: [
              Tab(text: 'Top Batsmen'),
              Tab(text: 'Top Bowlers'),
            ],
          ),
        ),
        body: isLoading
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
            : TabBarView(
          children: [
            ListView.builder(
              itemCount: batsmenName.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            PlayerProfile(playerId: batsmenId[index]),
                      ),
                    );
                  },
                  child: Container(
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
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundImage: NetworkImage(
                                      batsmenImage[index]),
                                ),
                                SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      batsmenName[index],
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          batsmenType[index],
                                          style: TextStyle(
                                            fontWeight: FontWeight.w300,
                                            color: Colors.white,
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        getPlayerTypeLogo(
                                            batsmenType[index]),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  batsmenRuns[index].toString(),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                Text(
                                  'Runs',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            ListView.builder(
              itemCount: bowlersName.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            PlayerProfile(playerId: bowlersId[index]),
                      ),
                    );
                  },
                  child: Container(
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
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundImage: NetworkImage(
                                      bowlersImage[index]),
                                ),
                                SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      bowlersName[index],
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          bowlersType[index],
                                          style: TextStyle(
                                            fontWeight: FontWeight.w300,
                                            color: Colors.white,
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        getPlayerTypeLogo(
                                            bowlersType[index]),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  bowlersWickets[index].toString(),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                Text(
                                  'Wickets',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
