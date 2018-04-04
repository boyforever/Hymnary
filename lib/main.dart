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

final _biggerFont = const TextStyle(fontSize: 14.0);
enum Language { english, chinese }
final Map hymnBook = {"english": new List<Song>(), "chinese": new List<Song>()};
final Map bookTitles = {"english": "Hymnary", "chinese": "聖徒詩歌"};

class ContentsState extends State<Contents>{  
  double _fontScale = 1.0;
  var _selectedSongIndex = 0;  
  var _selectedLanguage = Language.english;  

  void _switchLanguage(){ setState((){ _selectedLanguage = _selectedLanguage == Language.english ? Language.chinese : Language.english;}); }
  void _decreaseFontScale(){ setState((){_fontScale = _fontScale * 0.9;}); }  
  void _increaseFontScale(){ setState((){_fontScale = _fontScale * 1.1;}); }
  
  String _getEnumValue(String value) => value.toString().substring(value.toString().indexOf('.')+1); 
  String _getLanguage() => _getEnumValue(_selectedLanguage.toString());   
  void _setData(Map _library) {
    for (var value in Language.values) {
      var key = _getEnumValue(value.toString());
      for(var i=0; i<_library[key]['chapter'].length; i++){
        var _song = '';
        for(int j=0; j<_library[key]['chapter'][i]['stanza'].length; j++){
          if(_library[key]['chapter'][i]['stanza'].length > 1){
            _song += '\n(' + (j+1).toString() + ')\n';
          }
          _song += _library[key]['chapter'][i]['stanza'][j].trim();
        }
        hymnBook[key].add(new Song(i+1, _library[key]['chapter'][i]['title'].toString().toUpperCase(), _song));
      }
    }
  }

  List<Widget> _showSelectedSong(int index){
    List<Widget> w=[];
    if (index < 0 || hymnBook[_getLanguage()].length == 0) return w;
    var _song = hymnBook[_getLanguage()][index];
    if (_song == null) return w;
    w.add(new Text( _song.number.toString() + ' ' + _song.title, textAlign: TextAlign.center,style: new TextStyle(fontFamily: "Rock Salt", fontSize: 14.0 * _fontScale, fontWeight: FontWeight.bold),));    
    w.add(new Text( _song.lyric, style: new TextStyle(fontSize: 16.0 * _fontScale), textAlign: TextAlign.center,));
    return w;
  }

  Widget _list(Song root){
    return new ListTile(title: new Text(root.number.toString().padLeft(3) + ' - ' +root.title, style: _biggerFont,), onTap: (){
      setState((){
        Navigator.of(context).pop();
        _selectedSongIndex = root.number - 1;
        _showSelectedSong(_selectedSongIndex);
      });
    },);
  }

  @override
  void initState() {
    super.initState();
    widget.storage.readFile().then((Map value){
      setState((){
        _setData(value);
      });
    });
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
        _controller.clear();
        _selectedSongIndex = value == ''? -1 : int.parse(value) - 1 ;
        _showSelectedSong(value == ''? -1 : int.parse(value) - 1 );      
      });},
    );

    return new Scaffold(
      drawer: new Drawer(
        child: new ListView.builder(
          itemBuilder: (BuildContext context, int index) => _list(hymnBook[_getLanguage()][index]),
          itemCount: 716,
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
      body: new SingleChildScrollView( //consider pageview here
        child: new ListBody(
          children: _showSelectedSong(_selectedSongIndex),           
        ),        
      )
    );
  }
}