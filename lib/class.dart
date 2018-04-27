import 'dart:async' show Future;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class Song {
  Song(this.number, this.title, this.lyric);
  final int number;
  final String title;
  final String lyric;
}

class ContentStorage {
  Future<Map> readFile() async {
    try{
      String result = await rootBundle.loadString('assets/hymn.json');
      return JSON.decode(result);
    } catch(e) {
      return null;
    }
  }
}

class LyricCard extends StatelessWidget {
  const LyricCard({Key key, @required this.song, this.fontSize}) : super(key: key);
  final song;
  final fontSize;
  @override
  Widget build(BuildContext context) {
    return new Card(
      color: Colors.white,
      child: new SingleChildScrollView(
        child: new ListBody(
          children: <Widget>[
            new Text( song.number.toString() + ' ' + song.title, textAlign: TextAlign.center,style: new TextStyle(fontFamily: "Rock Salt", fontSize: fontSize, fontWeight: FontWeight.bold),),    
            new Text( song.lyric, style: new TextStyle(fontSize: fontSize), textAlign: TextAlign.center,)
          ],
        ),
      ),
    );
  }
}



class CardsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
  }

}