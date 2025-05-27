import 'package:flutter/material.dart';

class LocationsPage extends StatelessWidget {
  const LocationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Example data (replace with your data model)
    final locations = [
      {'name': '123', 'subtitle': 'Greenwich Mean Time'},
      {
        'name': 'Aylesbury Supervalu Tallaght',
        'subtitle': 'Greenwich Mean Time',
      },
      {
        'name': 'Fortunestown Supervalu Tallaght',
        'subtitle': 'Greenwich Mean Time',
      },
      {
        'name': 'Killinarden Centra Tallaght',
        'subtitle': 'Greenwich Mean Time',
      },
      {'name': 'Sprinfield Centra Tallaght', 'subtitle': 'Greenwich Mean Time'},
    ];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Locations',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: ListView(
        children: [
          // Info Card
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("📍", style: TextStyle(fontSize: 22)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: RichText(
                      text: const TextSpan(
                        style: TextStyle(color: Colors.black, fontSize: 14),
                        children: [
                          TextSpan(
                            text: 'Locations',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text:
                                ' may be departments or a physical place of work or work site.',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Add Location
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(Icons.add, color: Colors.deepPurple[700]),
                const SizedBox(width: 8),
                Text(
                  'Add Location',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          // All locations
          ListTile(
            leading: Icon(Icons.location_on, color: Colors.grey[600]),
            title: const Text('All locations'),
          ),
          // Location list
          ...locations.map(
            (loc) => ListTile(
              leading: Icon(Icons.location_on, color: Colors.grey[600]),
              title: Text(
                loc['name']!,
                style: TextStyle(
                  color:
                      loc['name'] == '123' ? Colors.deepPurple : Colors.black,
                  decoration:
                      loc['name'] == '123'
                          ? TextDecoration.underline
                          : TextDecoration.none,
                ),
              ),
              subtitle: Text(loc['subtitle']!),
              trailing: Text(
                'EDIT',
                style: TextStyle(
                  color: Colors.deepPurple[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () {
                // TODO: Handle location tap
              },
            ),
          ),
        ],
      ),
    );
  }
}
