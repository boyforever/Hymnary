import 'dart:async' show Future;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/foundation.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context){
    return new MaterialApp(
      title: 'Hymnary',
      theme: new ThemeData(primaryColor: Colors.blue,),
      home: new Contents(storage: new ContentStorage(),),
    );
  }
}

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

class Contents extends StatefulWidget{
  final ContentStorage storage;
  Contents({Key key, @required this.storage}) : super(key: key);
  @override
  ContentsState createState() => new ContentsState();
}

final _biggerFont = const TextStyle(fontSize: 16.0);
enum Language { english, chinese }
final Map hymnBook = {"english": new List<Song>(), "chinese": new List<Song>()};
final Map bookTitles = {"english": "Hymnary", "chinese": "聖徒詩歌"};

class ContentsState extends State<Contents>{  
  double _fontScale = 1.0;
  var _selectedIndex = 0;  
  var _selectedLanguage = Language.english;  

  @override
  void initState() {
    super.initState();
    widget.storage.readFile().then((Map value){
      setState((){
        _setData(value);
      });
    });
  }

  void _switchLanguage(){ setState((){ _selectedLanguage = _selectedLanguage == Language.english ? Language.chinese : Language.english;}); }
  void _decreaseFontScale(){ setState((){_fontScale = _fontScale * 0.9;}); }  
  void _increaseFontScale(){ setState((){_fontScale = _fontScale * 1.1;}); }
  
  String _getEnumValue(String value) => value.toString().substring(value.toString().indexOf('.')+1); 
  String _getLanguage() => _getEnumValue(_selectedLanguage.toString());   

  Widget _list(Song root){
    return new ListTile(title: new Text(root.title, style: _biggerFont,), onTap: (){
      setState((){
        _selectedIndex = root.number - 1;
        Navigator.of(context).pop();
        _showSelectedSong();
      });
    },);
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController _controller = new TextEditingController();
    Widget _inputBox = new TextField(
      controller: _controller,
      keyboardType: TextInputType.number,       
      decoration: new InputDecoration(icon: new Icon(Icons.search, color: Colors.white,), labelText: bookTitles[_getLanguage()], labelStyle: new TextStyle(fontWeight: FontWeight.bold, color: Colors.white)), 
      autocorrect: false, 
      autofocus: false, 
      style: new TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
      onSubmitted: (String value){setState((){
        if(value != ''){ _selectedIndex = int.parse(value) - 1;}
        _controller.clear();
        _showSelectedSong();      
      });},
    );

    return new Scaffold(
      drawer: new Drawer(
        child: new ListView.builder(
          itemBuilder: (BuildContext context, int index) => _list(hymnBook[_getLanguage()][index]),
          itemCount: hymnBook.length,
        ),
      ),
      appBar: new AppBar(
        title:  _inputBox,
        actions: <Widget>[
          new IconButton(icon: new Icon(Icons.add), onPressed: _increaseFontScale),
          new IconButton(icon: new Icon(Icons.remove), onPressed: _decreaseFontScale),
          new IconButton(icon: new Icon(Icons.translate), onPressed: _switchLanguage),
        ],
      ),
      body: new SingleChildScrollView(
        child: new ListBody(
          children: _showSelectedSong(), 
        ),
      )
    );
  }

  void _setData(Map _library) {
    for (var value in Language.values) {
      var key = _getEnumValue(value.toString());
      for(var i=0; i<_library[key]['chapter'].length; i++){
        var _song = '';
        for(int j=0; j<_library[key]['chapter'][_selectedIndex]['stanza'].length; j++){
          _song += '(' + (j+1).toString() + ')\n' + _library[key]['chapter'][i]['stanza'][j]['line'] + '\n' + _library[key]['chapter'][i]['stanza'][j]['chord'] + '\n';
        }
        hymnBook[key].add(new Song(i+1, _library[key]['chapter'][i]['title'].toString().toUpperCase(), _song));
      }
    }
  }

  List<Widget> _showSelectedSong(){
    List<Widget> w=[];
    if (_selectedIndex <= 0) _selectedIndex = 0;
    if (hymnBook[_getLanguage()].length == 0) return w;
    var _song = hymnBook[_getLanguage()][_selectedIndex];
    if (_song == null) return w;
    w.add(new Text( _song.number.toString() + ' ' + _song.title, textAlign: TextAlign.center,style: new TextStyle(fontFamily: "Rock Salt", fontSize: 18.0 * _fontScale, fontWeight: FontWeight.bold),));    
    w.add(new Text( _song.lyric, style: new TextStyle(fontSize: 16.0 * _fontScale),));
    return w;
  }
}