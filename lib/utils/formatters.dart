import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  static String tanggal(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  static String tanggalPanjang(DateTime date) {
    return DateFormat('dd MMMM yyyy', 'id_ID').format(date);
  }
}
