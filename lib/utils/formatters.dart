import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  static const List<String> _bulan = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  static String tanggal(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  static String tanggalPanjang(DateTime date) {
    return '${date.day} ${_bulan[date.month - 1]} ${date.year}';
  }

  static String bulanTahun(DateTime date) {
    return '${_bulan[date.month - 1]} ${date.year}';
  }

  static String rupiah(num value) {
    final number = value.round().toString();
    final formatted = number.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => '.',
    );
    return 'Rp $formatted';
  }

  static num toNumber(Object? value) {
    if (value is num) return value;
    return num.tryParse(value?.toString() ?? '') ?? 0;
  }

  static DateTime? parseDate(Object? value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }
}
