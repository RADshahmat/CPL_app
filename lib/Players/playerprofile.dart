import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:loading_indicator/loading_indicator.dart';
import 'package:nb_utils/nb_utils.dart';

class PlayerProfile extends StatefulWidget {
  final String playerId;
  const PlayerProfile({Key? key, required this.playerId}) : super(key: key);

  @override
  _PlayerProfileState createState() => _PlayerProfileState();
}

class _PlayerProfileState extends State<PlayerProfile> {
  final List<String> playersName = [];
  final List<String> playersImage = [];
  final List<String> playersType = [];
  final List<String> playersTeam = [];
  final List<String> playersMatch = [];
  final List<String> playersRuns = [];
  final List<String> playersSR = [];
  final List<String> playersWickets = [];
  final List<String> playersEcn = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTeamPlayersFromServer();
  }

  Future<void> fetchTeamPlayersFromServer() async {
    var url =
        'http://93.127.166.229:8080/rest_apis/player_profile.php?team_id=${widget.playerId}';

    try {
      http.Response response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        //print(data);
        setState(() {
          for (var item in data) {
            if (item.containsKey('name')) {
              playersName.add(item['name']);
            }
            if (item.containsKey('player_image')) {
              playersImage.add(item['player_image']);
            }
            if (item.containsKey('player_type')) {
              playersType.add(item['player_type']);
            }
            if (item.containsKey('team_name')) {
              playersTeam.add(item['team_name']);
            }
            if (item.containsKey('matches')) {
              playersMatch.add(item['matches']);
            }
            if (item.containsKey('runs')) {
              playersRuns.add(item['runs']);
            }
            if (item.containsKey('sr')) {
              playersSR.add(item['sr']);
            }
            if (item.containsKey('wickets')) {
              playersWickets.add(item['wickets']);
            }
            if (item.containsKey('ecn')) {
              playersEcn.add(item['ecn']);
            }
          }
          isLoading = false;
        });
      } else {
        //print('Request failed with status: ${response.statusCode}');
      }
    } catch (error) {
      //print('Error fetching data: $error');
    }
  }

  Widget getPlayerImage(String playerType) {
    switch (playerType.toLowerCase()) {
      case 'all-rounder':
        return Image.asset('assets/images/all_rounder.png');
      case 'batsman':
        return Image.asset('assets/images/batsman.png');
      case 'bowler'||'bowller':
        return Image.asset('assets/images/bowler.png');
      case 'wicketkeeper':
        return Image.asset('assets/images/wk.png');
      default:
        return SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    //print('baler kaka naki');
    //print(widget.playerId);
    return Scaffold(
      backgroundColor: Color.fromRGBO(44, 62, 80, 1),
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(34, 49, 63, 1),
        title: isLoading
            ? Text(
                'Loading...',
                style: TextStyle(color: Colors.white),
              )
            : Text(
                playersName[0],
                style: TextStyle(color: Colors.white),
              ),
        iconTheme: IconThemeData(color: Colors.white),
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
          : SingleChildScrollView(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      height: MediaQuery.of(context).size.height / 2,
                      child: Stack(
                        alignment: Alignment.topCenter,
                        children: <Widget>[
                          ClipPath(
                            clipper: null,
                            child: Image.network(
                              playersImage[0],
                              width: 350,
                              height: MediaQuery.of(context).size.height / 2,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Stack(
                                alignment: Alignment.bottomLeft,
                                children: <Widget>[
                                  Stack(
                                    alignment: Alignment.bottomRight,
                                    children: <Widget>[
                                      ClipPath(
                                        clipper: null,
                                        child: Image.network(
                                          playersImage[0],
                                          width: 80,
                                          height: 80,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                          .cornerRadiusWithClipRRect(45.0)
                                          .paddingOnly(left: 16, top: 16),
                                      Container(
                                        height: 35,
                                        width: 35,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          color: Colors.white,
                                        ),
                                        child: Container(
                                          child: getPlayerImage(playersType[0]),
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                              Container(
                                margin: EdgeInsets.only(
                                    top: MediaQuery.of(context).size.height *
                                        .38),
                                height: MediaQuery.of(context).size.height,
                                padding: EdgeInsets.only(
                                    top: 0, right: 8, bottom: 5),
                                decoration: BoxDecoration(
                                  color: Color.fromRGBO(44, 62, 80, .6),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: <Widget>[
                                    Text(
                                      playersName[0],
                                      style: primaryTextStyle(
                                        color: const Color.fromARGB(
                                            255, 255, 255, 255),
                                        size: 24,
                                      ),
                                    ).paddingOnly(left: 8, top: 5),
                                    Text(
                                      playersTeam[0],
                                      style: primaryTextStyle(
                                        color: const Color.fromARGB(
                                            255, 255, 255, 255),
                                        size: 16,
                                      ),
                                    ).paddingOnly(left: 16)
                                  ],
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                    16.height,
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.white,
                      ),
                      child: Column(
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Expanded(
                                flex: 1,
                                child: Container(
                                  padding: EdgeInsets.all(16),
                                  transform:
                                      Matrix4.translationValues(0.0, 10.0, 0.0),
                                  child: Column(
                                    children: <Widget>[
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: <Widget>[
                                          Text(playersRuns[0],
                                              style: primaryTextStyle(
                                                color: Colors.black,
                                                size: 16,
                                              )),
                                          4.width,
                                          Text("Runs",
                                              style: primaryTextStyle(
                                                color: Colors.black,
                                                size: 16,
                                              )),
                                        ],
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(right: 16),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: <Widget>[
                                            Text(playersSR[0],
                                                style: primaryTextStyle(
                                                  color: Colors.black,
                                                  size: 16,
                                                )),
                                            4.width,
                                            Text("Strike Rate",
                                                style: primaryTextStyle(
                                                  color: Colors.black,
                                                  size: 16,
                                                )),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                      height: context.width() * 0.2,
                                      width: 1,
                                      color: Color.fromARGB(255, 217, 213, 213)
                                          .withOpacity(0.5))
                                  .paddingOnly(top: 8, bottom: 8),
                              Expanded(
                                flex: 1,
                                child: Container(
                                  padding: EdgeInsets.all(16),
                                  transform:
                                      Matrix4.translationValues(0.0, 10.0, 0.0),
                                  child: Column(
                                    children: <Widget>[
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: <Widget>[],
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(left: 16),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: <Widget>[],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              Expanded(
                                  flex: 1,
                                  child: Container(
                                      height: 0.5,
                                      color: Colors.grey.withOpacity(0.5))),
                              Container(
                                height: 90,
                                width: 90,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(50),
                                    color: Color.fromARGB(255, 230, 229, 229)),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text(playersMatch[0],
                                        style: primaryTextStyle(
                                          color: Colors.black,
                                          size: 16,
                                        )),
                                    Text("Matches",
                                        style: primaryTextStyle(
                                          color: Colors.black,
                                          size: 16,
                                        )),
                                  ],
                                ),
                              ).paddingOnly(right: 8, left: 8),
                              Expanded(
                                  flex: 1,
                                  child: Container(
                                      height: 0.5,
                                      color: const Color.fromARGB(
                                              255, 191, 187, 187)
                                          .withOpacity(0.5)))
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              Expanded(
                                flex: 1,
                                child: Container(
                                  padding: EdgeInsets.all(16),
                                  transform: Matrix4.translationValues(
                                      0.0, -15.0, 0.0),
                                  child: Column(
                                    children: <Widget>[
                                      Padding(
                                        padding: EdgeInsets.only(right: 16),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: <Widget>[],
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: <Widget>[],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                      height: context.width() * 0.2,
                                      width: 1,
                                      color: Colors.grey.withOpacity(0.5))
                                  .paddingOnly(top: 8, bottom: 8),
                              Expanded(
                                flex: 1,
                                child: Container(
                                  padding: EdgeInsets.all(16),
                                  transform: Matrix4.translationValues(
                                      0.0, -10.0, 0.0),
                                  child: Column(
                                    children: <Widget>[
                                      Padding(
                                        padding: EdgeInsets.only(left: 16),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: <Widget>[
                                            Text("Wickets",
                                                style: primaryTextStyle(
                                                  color: Colors.black,
                                                  size: 16,
                                                )),
                                            4.width,
                                            Text(playersWickets[0],
                                                style: primaryTextStyle(
                                                  color: Colors.black,
                                                  size: 16,
                                                )),
                                          ],
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: <Widget>[
                                          Text("Economy Rate",
                                              style: primaryTextStyle(
                                                color: Colors.black,
                                                size: 16,
                                              )),
                                          4.width,
                                          Text(playersEcn[0],
                                              style: primaryTextStyle(
                                                color: Colors.black,
                                                size: 16,
                                              )),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ]),
            ),
    );
  }
}
