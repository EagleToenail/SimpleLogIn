import 'package:flutter/material.dart';

class BreaksSummaryPage extends StatefulWidget {
  final int mealBreaks;
  final int mealBreakMinutes;
  final int restBreaks;
  final int restBreakMinutes;

  const BreaksSummaryPage({
    super.key,
    required this.mealBreaks,
    required this.mealBreakMinutes,
    required this.restBreaks,
    required this.restBreakMinutes,
  });

  @override
  State<BreaksSummaryPage> createState() => _BreaksSummaryPageState();
}

class _BreaksSummaryPageState extends State<BreaksSummaryPage> {
  int selectedBreakType = 0; // 0: Meal, 1: Rest
  int breakMinutes = 30;
  int mealBreaks = 1;
  int restBreaks = 0;

  @override
  void initState() {
    super.initState();
    selectedBreakType = widget.mealBreaks > 0 ? 0 : 1;
    breakMinutes =
        widget.mealBreaks > 0
            ? widget.mealBreakMinutes
            : widget.restBreakMinutes;
    mealBreaks = widget.mealBreaks;
    restBreaks = widget.restBreaks;
  }

  void _setBreakType(int type) {
    setState(() {
      selectedBreakType = type;
      if (type == 0) {
        mealBreaks = 1;
        restBreaks = 0;
      } else {
        mealBreaks = 0;
        restBreaks = 1;
      }
    });
  }

  void _setBreakMinutes(int mins) {
    setState(() {
      breakMinutes = mins;
    });
  }

  void _deleteBreak() {
    setState(() {
      mealBreaks = 0;
      restBreaks = 0;
      breakMinutes = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Breaks Summary'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              Navigator.pop(context, {
                'mealBreaks': mealBreaks,
                'mealBreakMinutes': selectedBreakType == 0 ? breakMinutes : 0,
                'restBreaks': restBreaks,
                'restBreakMinutes': selectedBreakType == 1 ? breakMinutes : 0,
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (mealBreaks > 0 || restBreaks > 0)
              Row(
                children: [
                  Checkbox(
                    value: mealBreaks > 0 || restBreaks > 0,
                    onChanged: (val) {
                      if (val == false) _deleteBreak();
                    },
                  ),
                  Text(
                    selectedBreakType == 0
                        ? 'Meal Break (unpaid)'
                        : 'Rest Break (paid)',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text('Taken', style: TextStyle(color: Colors.red)),
                ],
              ),
            if (mealBreaks > 0 || restBreaks > 0)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text('$breakMinutes mins.'),
              ),
            // Break minutes selection
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children:
                  [10, 15, 20, 30, 45, 60]
                      .map(
                        (m) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          child: FilterChip(
                            label: Text('$m'),
                            selected: breakMinutes == m,
                            onSelected: (_) => _setBreakMinutes(m),
                            showCheckmark: false,
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                      )
                      .toList(),
            ),

            const SizedBox(height: 16),
            // Break Type
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Break Type',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            RadioListTile(
              value: 0,
              groupValue: selectedBreakType,
              onChanged: (val) => _setBreakType(0),
              title: const Text('Meal Break (unpaid)'),
            ),
            RadioListTile(
              value: 1,
              groupValue: selectedBreakType,
              onChanged: (val) => _setBreakType(1),
              title: const Text('Rest Break (paid)'),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: _deleteBreak,
                child: const Text(
                  'Delete Break',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
