import 'package:flutter/material.dart';

class SearchBar {
  String hintText;
  TextEditingController controller;
  SearchBar({
    this.hintText = "Search in Hymnary",
    this.controller
  }) {
    if(this.controller == null) this.controller = new TextEditingController();
    
  }
}