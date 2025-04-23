import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:loading_indicator/loading_indicator.dart';
import '../Players/playerprofile.dart';

class TeamDetailsPage extends StatefulWidget {
  final String teamId;
  const TeamDetailsPage({Key? key, required this.teamId}) : super(key: key);

  @override
  _TeamDetailsPageState createState() => _TeamDetailsPageState();
}

class _TeamDetailsPageState extends State<TeamDetailsPage> {
  final List<String> playersName = [];
  final List<String> playersImage = [];
  final List<String> playersType = [];
  final List<String> playersId = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTeamPlayersFromServer();
  }

  Future<void> fetchTeamPlayersFromServer() async {
    var url =
        'http://93.127.166.229:8080/rest_apis/allplayer.php?team_id=${widget.teamId}';

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
            if (item.containsKey('ID')) {
              playersId.add(item['ID']);
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
      case 'bowler' || 'bowller':
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
    //print(widget.teamId);
    return Scaffold(
      backgroundColor: Color.fromRGBO(44, 62, 80, 1),
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(34, 49, 63, 1),
        title: Text(
          'Team Details',
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
          : ListView.builder(
              itemCount: playersName.length,
              itemBuilder: (context, index) {
                return Container(
                  color: Color.fromRGBO(41, 57, 74, 1),
                  child: Card(
                    color: Color.fromRGBO(69, 116, 166, 1),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                PlayerProfile(playerId: playersId[index]),
                          ),
                        );
                      },
                      child: ListTile(
                        title: Text(
                          playersName[index],
                          style: TextStyle(
                              fontWeight: FontWeight.w500, color: Colors.white),
                        ),
                        subtitle: Text(
                          playersType[index],
                          style: TextStyle(
                              fontWeight: FontWeight.w300, color: Colors.white),
                        ),
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(
                            playersImage[index],
                          ),
                        ),
                        trailing: getPlayerImage(playersType[index]),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
