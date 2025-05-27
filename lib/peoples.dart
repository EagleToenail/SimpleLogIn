import 'package:flutter/material.dart';
import 'store.dart';
import 'package:provider/provider.dart';
import 'add_team_member.dart';

class PeoplesPage extends StatelessWidget {
  PeoplesPage({super.key});

  Widget _buildAvatar(String initials) {
    return CircleAvatar(
      backgroundColor: Colors.grey.shade300,
      child: Text(
        initials,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.split(" ");
    if (parts.length >= 2) {
      return parts[0][0] + parts[1][0];
    }
    return name.substring(0, 2).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    List<PeopleItem> people = Provider.of<AppStore>(context).people;
    final Map<String, List<Map<String, String>>> groupedPeople = {};

    for (final person in people) {
      final name = person.preferredName;
      if (name.isEmpty) continue; // Skip if name is empty

      final firstLetter = name[0].toUpperCase();

      groupedPeople.putIfAbsent(firstLetter, () => []);
      groupedPeople[firstLetter]!.add({
        "name": name,
        "status": "Not invited", // Default status
      });
    }

    return Scaffold(
      body: ListView.builder(
        itemCount: groupedPeople.length,
        itemBuilder: (context, index) {
          final sectionKey = groupedPeople.keys.elementAt(index);
          final people = groupedPeople[sectionKey]!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 0, 4),
                child: Text(
                  sectionKey,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ...people.map((person) {
                final initials = _getInitials(person["name"]!);
                return ListTile(
                  leading: _buildAvatar(initials),
                  title: Text(
                    person["name"]!,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle:
                      person["status"] != "(You)"
                          ? const Text("Not invited")
                          : null,
                  trailing:
                      person["status"] == "(You)"
                          ? const Text(
                            "(You)",
                            style: TextStyle(color: Colors.grey),
                          )
                          : null,
                );
              }).toList(),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Add invite functionality or show a dialog
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddTeamMemberPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
