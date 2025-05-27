import 'package:flutter/material.dart';

class SelectAreaPage extends StatelessWidget {
  const SelectAreaPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> areas = [
      {'name': '123', 'subtitle': 'Greenwich Mean Time'},
      {'name': 'kkkkkkk', 'subtitle': ''},
      {
        'name': 'Aylesbury Supervalu Tallaght',
        'subtitle': 'Greenwich Mean Time',
      },
      {'name': 'Guard', 'subtitle': ''},
      {
        'name': 'Fortunestown Supervalu Tallaght',
        'subtitle': 'Greenwich Mean Time',
      },
      {'name': 'Guard', 'subtitle': ''},
      {
        'name': 'Killinarden Centra Tallaght',
        'subtitle': 'Greenwich Mean Time',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Select area',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search functionality
            },
          ),
        ],
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          // Info card
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline, color: Colors.black87),
                  const SizedBox(width: 8),
                  Expanded(
                    child: RichText(
                      text: const TextSpan(
                        style: TextStyle(color: Colors.black87),
                        children: [
                          TextSpan(
                            text:
                                'Team members are scheduled to areas of work. ',
                          ),
                          TextSpan(
                            text: 'Areas may be roles, tasks or job sites.',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Area list
          Expanded(
            child: ListView.builder(
              itemCount: areas.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const Icon(Icons.business, color: Colors.grey),
                  title: Text(areas[index]['name']!),
                  subtitle:
                      areas[index]['subtitle']!.isNotEmpty
                          ? Text(areas[index]['subtitle']!)
                          : null,
                  trailing: TextButton(
                    onPressed: () {
                      // TODO: Implement edit functionality
                    },
                    child: const Text(
                      'EDIT',
                      style: TextStyle(color: Colors.deepPurple),
                    ),
                  ),
                  onTap: () {
                    // TODO: Implement area selection
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
