import 'package:flutter/material.dart';

class SearchBox extends StatefulWidget {
  final String _label;
  final TextEditingController _controller = new TextEditingController();
  final VoidCallback _onChanged;
  final VoidCallback _onSubmitted;

  SearchBox(this._label, this._onChanged(), this._onSubmitted);

  @override
  State<StatefulWidget> createState()  => new SearchBoxState();
}

class SearchBoxState extends State<SearchBox>{

  @override
  Widget build(BuildContext context) {
    
    return new TextField(
      controller: widget._controller,
      keyboardType: TextInputType.number,       
      decoration: new InputDecoration(
        icon: new Icon(Icons.search, color: Colors.white,), 
        labelText: widget._label, 
        labelStyle: new TextStyle(fontWeight: FontWeight.bold, color: Colors.white)
      ), 
      autocorrect: false, 
      autofocus: false, 
      style: new TextStyle(fontWeight: FontWeight.bold, color: Colors.white),          
      // onChanged: widget._onSubmitted,
      // onSubmitted: _onSubmitted(),
    );
  }  
}