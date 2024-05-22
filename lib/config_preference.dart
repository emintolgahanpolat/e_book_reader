import 'package:e_book_reader/config.dart';

abstract class SharedConfigPreference {
  void save(ReaderConfig config);
  ReaderConfig? load();
}
