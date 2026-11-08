// Fungsi bantu untuk menampilkan angka dan tanggal dalam format Indonesia.
// Dibuat manual supaya tidak perlu menambah package intl.

/// 12.0 -> "12", 0.8 -> "0,8", 6.5 -> "6,5"
String formatNumber(double value) {
  final rounded = (value * 100).round() / 100;
  var text = rounded.toStringAsFixed(2);
  // Buang nol di belakang koma: "12.00" -> "12", "0.80" -> "0.8"
  text = text.replaceFirst(RegExp(r'\.?0+$'), '');
  return text.replaceAll('.', ',');
}

/// "12 kg", "0,8 kg"
String formatQuantity(double value, String unit) =>
    '${formatNumber(value)} $unit';

/// Mengubah teks input ("1,5" atau "1.5") menjadi angka. Null bila tidak valid.
double? parseNumber(String text) {
  final value = double.tryParse(text.trim().replaceAll(',', '.'));
  if (value == null || value.isNaN || value.isInfinite) return null;
  return value;
}

const _weekdays = [
  'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu',
];
const _months = [
  'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli',
  'Agustus', 'September', 'Oktober', 'November', 'Desember',
];
const _shortMonths = [
  'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt',
  'Nov', 'Des',
];

/// "Minggu, 8 November 2026"
String formatDateLong(DateTime date) =>
    '${_weekdays[date.weekday - 1]}, ${date.day} '
    '${_months[date.month - 1]} ${date.year}';

/// "8 Nov, 22:45"
String formatDateTime(DateTime date) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${date.day} ${_shortMonths[date.month - 1]}, '
      '${two(date.hour)}:${two(date.minute)}';
}
