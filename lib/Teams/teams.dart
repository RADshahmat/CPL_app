import 'package:flutter/material.dart';
import 'team_details_page.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:loading_indicator/loading_indicator.dart';

class TeamsPage extends StatefulWidget {
  @override
  _TeamsPageState createState() => _TeamsPageState();
}

class _TeamsPageState extends State<TeamsPage> {
  final List<String> TeamsName = [];
  final List<String> TeamsImage = [];
  final List<String> TeamsId = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTeamsFromServer();
  }

  Future<void> fetchTeamsFromServer() async {
    var url = 'http://93.127.166.229:8080/rest_apis/getteams.php';

    try {
      //print('dhokse');
      http.Response response = await http.get(Uri.parse(url));
      //print('Hoise');
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        //print(data);
        setState(() {
          for (var item in data) {
            if (item.containsKey('team_name')) {
              TeamsName.add(item['team_name']);
            }
            if (item.containsKey('image_add')) {
              TeamsImage.add(item['image_add']);
            }
            if (item.containsKey('ID')) {
              TeamsId.add(item['ID'].toString());
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(44, 62, 80, 1),
      appBar: AppBar(
        title: Text(
          'Teams',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color.fromRGBO(41, 57, 74, 1),
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
        itemCount: TeamsName.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      TeamDetailsPage(teamId: TeamsId[index]),
                ),
              );
            },
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              width: double.infinity,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: 150,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(TeamsImage[index]),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: EdgeInsets.all(5),
                        color: Color.fromRGBO(44, 62, 80, .7),
                        child: Text(
                          TeamsName[index],
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
