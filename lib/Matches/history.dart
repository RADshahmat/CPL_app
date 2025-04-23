import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:loading_indicator/loading_indicator.dart';


class HistoryPage extends StatefulWidget {
  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final List<Map<String, dynamic>> historyData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchHistoryFromServer();
  }

  Future<void> fetchHistoryFromServer() async {
    var url = 'http://93.127.166.229:8080/rest_apis/get_history.php';

    try {
      http.Response response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        setState(() {
          historyData.addAll(List<Map<String, dynamic>>.from(data));
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
          'History',
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
        itemCount: historyData.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {

            },
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Color.fromRGBO(41, 57, 74, 1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    historyData[index]['tournament_name'],
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(historyData[index]['winner_team_photo']),
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      Positioned(
                        bottom: 10,
                        left: 10,
                        child: Image.network(
                          historyData[index]['winner_team_logo'],
                          height: 50,
                          width: 50,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        bottom: 10,
                        right: 10,
                        child: Icon(
                          Icons.emoji_events,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Champion: ${historyData[index]['winner_team_name']}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'Runners-Up: ${historyData[index]['runners_up_team_name'] ?? 'N/A'}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'Man of the Tournament: ${historyData[index]['motournament'] ?? 'N/A'}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
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
