import 'dart:convert';

import 'package:e_book_reader/config.dart';
import 'package:e_book_reader/config_preference.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedConfigPrefrenceImpl extends SharedConfigPreference {
  final SharedPreferences _pref;
  SharedConfigPrefrenceImpl(this._pref);
  @override
  ReaderConfig? load() {
    ReaderConfig? config;
    // String? data = _pref.getString("ReaderConfig");
    // if (data == null) {
    //   return null;
    // }
    // try {
    //   config = ReaderConfig.fromJson(json.decode(data));
    // } catch (e) {
    //   print(e);
    // }
    return config;
  }

  @override
  void save(ReaderConfig config) {
    _pref.setString("ReaderConfig", json.encode(config.toJson()));
  }
}
