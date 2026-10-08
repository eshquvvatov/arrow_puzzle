const _months = [
  'yanvar',
  'fevral',
  'mart',
  'aprel',
  'may',
  'iyun',
  'iyul',
  'avgust',
  'sentabr',
  'oktabr',
  'noyabr',
  'dekabr',
];

/// Haftaning qisqa nomlari, dushanbadan boshlab.
const weekdayShortUz = ['Du', 'Se', 'Cho', 'Pa', 'Ju', 'Sha', 'Ya'];

/// "2-iyul, 2026" ko'rinishida.
String formatDateUz(DateTime d) => '${d.day}-${_months[d.month - 1]}, ${d.year}';

/// "Iyul 2026" ko'rinishida (kalendar sarlavhasi).
String monthTitleUz(DateTime d) {
  final n = _months[d.month - 1];
  return '${n[0].toUpperCase()}${n.substring(1)} ${d.year}';
}
