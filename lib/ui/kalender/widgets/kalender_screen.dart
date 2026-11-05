import 'package:flutter/material.dart';

class KalenderPage extends StatefulWidget {
  const KalenderPage({super.key});

  @override
  State<KalenderPage> createState() => _KalenderPageState();
}

class _KalenderPageState extends State<KalenderPage> {
  static const Color _background = Color(0xFFFFF7D4);
  static const Color _calendarBackground = Color(0xFF854836);
  static const Color _primaryText = Color(0xFF4C3D3D);
  static const Color _purple = Color(0xFF7D8CFF);
  static const Color _red = Color(0xFFED6969);
  static const Color _lightGreen = Color(0xFFABD29E);
  static const Color _brightGreen = Color(0xFF30C100);

  static const TextStyle _titleStyle = TextStyle(
    color: _primaryText,
    fontSize: 20,
    fontFamily: 'Inter',
    fontWeight: FontWeight.w700,
  );

  static const TextStyle _monthStyle = TextStyle(
    color: Colors.black,
    fontSize: 20,
    fontFamily: 'Inter',
    fontWeight: FontWeight.w500,
  );

  static const TextStyle _weekdayStyle = TextStyle(
    color: Colors.black,
    fontSize: 15,
    fontFamily: 'Inter',
    fontWeight: FontWeight.w500,
  );

  static const TextStyle _legendStyle = TextStyle(
    color: Colors.black,
    fontSize: 10,
    fontFamily: 'Inter',
    fontWeight: FontWeight.w400,
  );

  static const List<String> _monthNames = [
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

  static const List<String> _shortMonthNames = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];

  static const List<String> _weekdays = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  late DateTime _visibleMonth;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _visibleMonth = DateTime(now.year, now.month);
    _selectedDate = DateTime(now.year, now.month, now.day);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: Center(
        child: FittedBox(
          fit: BoxFit.contain,
          child: Container(
            width: 428,
            height: 926,
            clipBehavior: Clip.antiAlias,
            decoration: const BoxDecoration(color: _background),
            child: Stack(
              children: [
                Positioned(
                  left: 22,
                  top: 39,
                  child: SizedBox(
                    width: 38,
                    height: 38,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      splashRadius: 20,
                      icon: const Icon(
                        Icons.chevron_left,
                        size: 30,
                        color: _primaryText,
                      ),
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                  ),
                ),
                const Positioned(
                  left: 57,
                  top: 46,
                  child: SizedBox(
                    width: 185,
                    height: 31,
                    child: Text('Kalender', style: _titleStyle),
                  ),
                ),
                Positioned(
                  left: 25,
                  top: 106,
                  child: _buildCalendarCard(),
                ),
                Positioned(
                  left: 23,
                  top: 576,
                  child: _buildEventCard(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarCard() {
    final days = _buildVisibleDays();
    final weeks = List.generate(
      6,
      (index) => days.sublist(index * 7, index * 7 + 7),
    );

    return Container(
      width: 377,
      height: 441,
      decoration: BoxDecoration(
        color: _calendarBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 8,
            top: 10,
            child: IconButton(
              key: const Key('calendar-prev'),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints.tightFor(
                width: 40,
                height: 40,
              ),
              icon: const Icon(
                Icons.chevron_left,
                size: 30,
                color: Colors.black,
              ),
              onPressed: () => _changeMonth(-1),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 15,
            child: Center(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _showMonthYearPicker,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${_monthNames[_visibleMonth.month - 1]} ${_visibleMonth.year}',
                        key: const Key('calendar-title'),
                        style: _monthStyle,
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_drop_down, color: Colors.black, size: 22),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: 8,
            top: 10,
            child: IconButton(
              key: const Key('calendar-next'),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints.tightFor(
                width: 40,
                height: 40,
              ),
              icon: const Icon(
                Icons.chevron_right,
                size: 30,
                color: Colors.black,
              ),
              onPressed: () => _changeMonth(1),
            ),
          ),
          Positioned(
            left: 29,
            right: 17,
            top: 68,
            child: Row(
              children: _weekdays
                  .map(
                    (day) => Expanded(
                      child: Center(
                        child: Text(day, style: _weekdayStyle),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          Positioned(
            left: 29,
            right: 17,
            top: 112,
            child: Column(
              children: weeks.map(_buildWeek).toList(),
            ),
          ),
          Positioned(
            left: 28,
            top: 386,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLegend(_purple, 'Hari Ini'),
                const SizedBox(height: 6),
                _buildLegend(_red, 'Jatuh Tempo Pembayaran'),
              ],
            ),
          ),
          Positioned(
            left: 192,
            top: 387,
            child: _buildLegend(_lightGreen, 'Maintenance'),
          ),
        ],
      ),
    );
  }

  List<DateTime> _buildVisibleDays() {
    final firstDay = DateTime(_visibleMonth.year, _visibleMonth.month, 1);
    final start = firstDay.subtract(Duration(days: firstDay.weekday - 1));
    return List.generate(
      42,
      (index) => DateTime(start.year, start.month, start.day + index),
    );
  }

  Widget _buildWeek(List<DateTime> days) {
    return SizedBox(
      height: 42,
      child: Row(
        children: days
            .map(
              (date) => Expanded(child: _buildDayCell(date)),
            )
            .toList(),
      ),
    );
  }

  Widget _buildDayCell(DateTime date) {
    final isCurrentMonth = date.month == _visibleMonth.month &&
        date.year == _visibleMonth.year;
    final isSelected = _isSameDay(date, _selectedDate);
    final isToday = _isSameDay(date, DateTime.now());
    final hasPayment = isCurrentMonth && date.day == 20;
    final hasMaintenance = isCurrentMonth && date.day == 27;
    final showTodayDot =
        isToday && !isSelected && !hasPayment && !hasMaintenance;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _selectDate(date),
      child: SizedBox(
        height: 42,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            if (isSelected)
              Positioned(
                top: 0,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: _purple,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            Positioned(
              top: isSelected ? 6 : 3,
              child: Text(
                '${date.day}',
                style: TextStyle(
                  color: isCurrentMonth
                      ? Colors.black
                      : const Color(0x664C3D3D),
                  fontSize: 14,
                  fontFamily: 'Inter',
                  fontWeight: isCurrentMonth
                      ? FontWeight.w500
                      : FontWeight.w300,
                ),
              ),
            ),
            if (hasPayment)
              Positioned(top: 29, child: _buildDot(_red)),
            if (hasMaintenance)
              Positioned(top: 29, child: _buildDot(_brightGreen)),
            if (showTodayDot)
              Positioned(top: 29, child: _buildDot(_purple)),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildDot(color),
        const SizedBox(width: 8),
        Text(label, style: _legendStyle),
      ],
    );
  }

  Widget _buildDot(Color color) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  Widget _buildEventCard() {
    final shortMonth = _shortMonthNames[_visibleMonth.month - 1];

    return Container(
      width: 377,
      height: 134,
      padding: const EdgeInsets.fromLTRB(27, 20, 12, 20),
      decoration: BoxDecoration(
        color: _calendarBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildEventRow(
            date: '20\n$shortMonth',
            title: 'Jatuh Tempo Pembayaran',
            color: _red,
          ),
          const SizedBox(height: 8),
          _buildEventRow(
            date: '27\n$shortMonth',
            title: 'Maintenance',
            color: _lightGreen,
          ),
        ],
      ),
    );
  }

  Widget _buildEventRow({
    required String date,
    required String title,
    required Color color,
  }) {
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              date,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 10,
                height: 1.15,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(width: 1, height: 24, color: const Color(0xFF878787)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 12,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _changeMonth(int delta) {
    setState(() {
      _visibleMonth = DateTime(
        _visibleMonth.year,
        _visibleMonth.month + delta,
      );
    });
  }

  void _showMonthYearPicker() async {
    int tempYear = _visibleMonth.year;
    int tempMonth = _visibleMonth.month;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: const Color(0xFFFFFCF5),
              title: const Text(
                'Pilih Bulan & Tahun',
                style: TextStyle(
                  color: Color(0xFF4C3D3D),
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              content: SizedBox(
                width: 300,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left),
                          onPressed: () {
                            setStateDialog(() {
                              tempYear--;
                            });
                          },
                        ),
                        Text(
                          '$tempYear',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Inter',
                            color: Color(0xFF4C3D3D),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right),
                          onPressed: () {
                            setStateDialog(() {
                              tempYear++;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 2.2,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: 12,
                      itemBuilder: (context, index) {
                        final monthIndex = index + 1;
                        final isSelected = monthIndex == tempMonth;
                        return InkWell(
                          onTap: () {
                            setStateDialog(() {
                              tempMonth = monthIndex;
                            });
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF7D8CFF)
                                  : const Color(0xFFF8EBD2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _shortMonthNames[index],
                              style: TextStyle(
                                color: isSelected ? Colors.white : const Color(0xFF4C3D3D),
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                fontFamily: 'Inter',
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Batal', style: TextStyle(color: Color(0xFF8A7C6B))),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF854836),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      _visibleMonth = DateTime(tempYear, tempMonth);
                    });
                    Navigator.of(context).pop();
                  },
                  child: const Text('Pilih'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _selectDate(DateTime date) {
    setState(() {
      _selectedDate = date;
      if (date.month != _visibleMonth.month ||
          date.year != _visibleMonth.year) {
        _visibleMonth = DateTime(date.year, date.month);
      }
    });
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
