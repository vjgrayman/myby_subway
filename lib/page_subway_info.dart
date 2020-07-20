import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'subway_api.dart' as api;
import 'subway_arrival.dart';
import 'dart:convert';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {

  TextEditingController _stationController =
  TextEditingController(
      text: api.defaultStation,
  );
  List<SubwayArrival> _data = [];
  bool _isLoading = false;

  List<Card> _buildCards() {
    print('>>> _data.length? ${_data.length}');

    if (_data.length == 0) {
      return <Card>[];
    }

    List<Card> res = [];
    for (SubwayArrival info in _data) {
      Card card = Card(
        color: Color(0xFF311d3f),
        child: Column(
          children: <Widget>[
            SizedBox(height: 15.0),
            AspectRatio(
              aspectRatio: 20 / 11,
              child: Image.asset(
                'assets/icon/subway.png',
                fit: BoxFit.scaleDown,
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      info.trainLineNm,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.0),
                    Text(
                      info.arvlMsg2,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
      res.add(card);
    }
    return res;
  }

  @override
  void initState() {
    super.initState();
    _getInfo();
  }

  _onClick() {
    _getInfo();
  }

  _getInfo() async {
    setState(() => _isLoading = true);

    String station = _stationController.text;
    var response = await http.get(api.buildUrl(station));
    String responseBody = response.body;
    print('res >> $responseBody');

    var json = jsonDecode(responseBody);
    Map<String, dynamic> errorMessage = json['errorMessage'];

    if (errorMessage['status'] != api.STATUS_OK) {
      setState(() {
        final String errMessage = errorMessage['message'];
        print('error >> $errMessage');
        _data = const [];
        _isLoading = false;
      });
      return;
    }

    List<dynamic> realtimeArrivalList = json['realtimeArrivalList'];
    final int cnt = realtimeArrivalList.length;

    List<SubwayArrival> list = List.generate(cnt, (int i) {
      Map<String, dynamic> item = realtimeArrivalList[i];
      return SubwayArrival(
        item['rowNum'],
        item['subwayId'],
        item['trainLineNm'],
        item['subwayHeading'],
        item['arvlMsg2'],
      );
    });
    setState(() {
      _data = list;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF311d3f),
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: Text('myby Subway',
        ),
      ),
      body: _isLoading ? Center(child: CircularProgressIndicator()) : Column(

        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            height: 60,
            child: Row(
              children: <Widget>[
                Text('역 이름'),
                SizedBox(width: 30,),
                Container(
                  width: 160,
                  child: TextField(
                    style: TextStyle(
                      fontSize: 24.0,
                    ),
                    controller: _stationController,
                  ),
                ),
                Expanded(
                  child: SizedBox.shrink(),
                ),
                RaisedButton(
                  color: Color(0xFFe23e57),
                  child: Text('SEARCH'),
                  onPressed: _onClick,
                ),
              ],
            ),
          ),
          SizedBox(height: 10,),
          Padding(padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
            child: Text('ARRIVALS'),
          ),
          SizedBox(height: 10,),
          Flexible(
            child: GridView.count(
              crossAxisCount: 2,
              children: _buildCards(),
            ),
          ),
        ],
      ),
    );
  }
}

