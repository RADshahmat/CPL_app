import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:loading_indicator/loading_indicator.dart';
import 'dart:convert';

class CricketPointsTablePage extends StatefulWidget {
  const CricketPointsTablePage({Key? key}) : super(key: key);

  @override
  _CricketPointsTablePageState createState() => _CricketPointsTablePageState();
}

class _CricketPointsTablePageState extends State<CricketPointsTablePage> {
  late List<Map<String, dynamic>> _pointsTableData = [];

  @override
  void initState() {
    super.initState();
    _fetchPointsTableData();
  }

  Future<void> _fetchPointsTableData() async {
    try {
      final response = await http.get(Uri.parse('http://93.127.166.229:8080/rest_apis/get_points_table.php'));
      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        //print('Response data: $responseData'); // Debug statement
        setState(() {
          _pointsTableData = List<Map<String, dynamic>>.from(responseData.map((item) {
            // Convert 'net_run_ret' to double
            double netRunRet = double.parse(item['net_run_ret_decimal'].toString());
            // Update the item with the converted value
            item['net_run_ret'] = netRunRet;
            return item;
          }));
        });
      } else {
        throw Exception('Failed to fetch data: ${response.statusCode}');
      }
    } catch (e) {
      //print('Error: $e'); // Debug statement
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Points Table', style: TextStyle(color: Colors.white)),
        backgroundColor: Color.fromRGBO(44, 62, 80, 1),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      backgroundColor: Color.fromRGBO(44, 62, 80, 1), // Set background color
      body: _pointsTableData.isEmpty
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
          : Column(
        children: [
          Container(
            margin: EdgeInsets.all(10),
            child: Table(
              border: TableBorder.all(color: Colors.black),
              columnWidths: {
                0: FlexColumnWidth(1), // 'Sl' column
                1: FlexColumnWidth(4), // 'Team' column
                2: FlexColumnWidth(1), // 'M' column
                3: FlexColumnWidth(1), // 'W' column
                4: FlexColumnWidth(1), // 'L' column
                5: FlexColumnWidth(1), // 'P' column
                6: FlexColumnWidth(2), // 'NRR' column
              },
              children: [
                TableRow(
                  decoration: BoxDecoration(color: Color.fromRGBO(66, 65, 35, 1.0)),
                  children: [
                    TableCell(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                        child: Text(
                          'Sl',
                          style: TextStyle(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                        child: Text(
                          'Team',
                          style: TextStyle(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                        child: Text(
                          'M',
                          style: TextStyle(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                        child: Text(
                          'W',
                          style: TextStyle(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                        child: Text(
                          'L',
                          style: TextStyle(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                        child: Text(
                          'P',
                          style: TextStyle(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        child: Text(
                          'NRR',
                          style: TextStyle(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
                for (int i = 0; i < _pointsTableData.length; i++)
                  TableRow(
                    decoration: BoxDecoration(color: Color.fromRGBO(145, 176, 206, 1.0)),
                    children: [
                      TableCell(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                          child: Text(
                            (i + 1).toString(),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                          child: Text(
                            _pointsTableData[i]['team_name'],
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                          child: Text(
                            _pointsTableData[i]['played'].toString(),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                          child: Text(
                            _pointsTableData[i]['win'],
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                          child: Text(
                            _pointsTableData[i]['loss'].toString(),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                          child: Text(
                            ((int.parse(_pointsTableData[i]['win']) * 2) + (int.parse(_pointsTableData[i]['draw']) * 2)).toString(), // 'P' column, points = (win * 2) + (draw * 2)
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          child: Text(
                            _pointsTableData[i]['net_run_ret'].toStringAsFixed(3),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
