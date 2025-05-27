import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(home: AddTeamMemberPage()));
}

class AddTeamMemberPage extends StatefulWidget {
  const AddTeamMemberPage({Key? key}) : super(key: key);

  @override
  _AddTeamMemberPageState createState() => _AddTeamMemberPageState();
}

class _AddTeamMemberPageState extends State<AddTeamMemberPage> {
  TextEditingController fullNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  String accessLevel = 'Employee';
  String location = '123 Greenwich Mean Time';

  Future<void> _selectAccessLevel(BuildContext context) async {
    final result = await showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return AccessLevelBottomSheet(selectedAccessLevel: accessLevel);
      },
    );

    if (result != null) {
      setState(() {
        accessLevel = result as String;
      });
    }
  }

  Future<void> _selectLocation(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LocationsPage()),
    );

    if (result != null) {
      setState(() {
        location = result as String;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add team member'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Full Name
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextFormField(
                      controller: fullNameController,
                      decoration: const InputDecoration(
                        labelText: 'Full name',
                        border: InputBorder.none, // Remove border
                        contentPadding: EdgeInsets.all(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Email
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextFormField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email (optional)',
                        border: InputBorder.none, // Remove border
                        contentPadding: EdgeInsets.all(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text('Invite to use Deputy'),
                      const Spacer(),
                      Switch(value: false, onChanged: (value) {}),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Access Level
                  InkWell(
                    onTap: () {
                      _selectAccessLevel(context);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          const Icon(Icons.lock), // Add an icon
                          Text(
                            accessLevel,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios, size: 16),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Location
                  InkWell(
                    onTap: () {
                      _selectLocation(context);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          const Icon(Icons.location_on), // Add an icon
                          Text(
                            location,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios, size: 16),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton(
                  onPressed: () {
                    // TODO: Add another logic
                  },
                  child: const Text('Add another'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // TODO: Add and close logic
                  },
                  child: const Text('Add and close'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AccessLevelBottomSheet extends StatefulWidget {
  final String selectedAccessLevel;

  const AccessLevelBottomSheet({Key? key, required this.selectedAccessLevel})
    : super(key: key);

  @override
  State<AccessLevelBottomSheet> createState() => _AccessLevelBottomSheetState();
}

class _AccessLevelBottomSheetState extends State<AccessLevelBottomSheet> {
  late String selectedAccessLevel;

  @override
  void initState() {
    super.initState();
    selectedAccessLevel = widget.selectedAccessLevel;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            title: const Text('System Administrator'),
            onTap: () {
              Navigator.pop(context, 'System Administrator');
            },
          ),
          ListTile(
            title: const Text('Supervisor'),
            onTap: () {
              Navigator.pop(context, 'Supervisor');
            },
          ),
          ListTile(
            title: const Text('Employee'),
            onTap: () {
              Navigator.pop(context, 'Employee');
            },
            trailing:
                selectedAccessLevel == 'Employee'
                    ? const Icon(Icons.check)
                    : null,
          ),
          ListTile(
            title: const Text('Location Manager'),
            onTap: () {
              Navigator.pop(context, 'Location Manager');
            },
          ),
          ListTile(
            title: const Text('Advisor'),
            onTap: () {
              Navigator.pop(context, 'Advisor');
            },
          ),
          ListTile(
            title: const Text('Understand access levels'),
            onTap: () {
              // TODO: Understand access levels logic
            },
          ),
        ],
      ),
    );
  }
}

class LocationsPage extends StatefulWidget {
  const LocationsPage({Key? key}) : super(key: key);

  @override
  State<LocationsPage> createState() => _LocationsPageState();
}

class _LocationsPageState extends State<LocationsPage> {
  String selectedLocation = '123 Greenwich Mean Time';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Locations'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.location_on), // Add location icon
            title: const Text('123 Greenwich Mean Time'),
            subtitle: const Text('Greenwich Mean Time'),
            trailing:
                selectedLocation == '123 Greenwich Mean Time'
                    ? const Icon(Icons.check)
                    : null,
            onTap: () {
              Navigator.pop(context, '123 Greenwich Mean Time');
            },
          ),
          ListTile(
            leading: const Icon(Icons.location_on), // Add location icon
            title: const Text('Aylesbury Supervalu Tallaght'),
            subtitle: const Text('Greenwich Mean Time'),
            trailing:
                selectedLocation == 'Aylesbury Supervalu Tallaght'
                    ? const Icon(Icons.check)
                    : null,
            onTap: () {
              Navigator.pop(context, 'Aylesbury Supervalu Tallaght');
            },
          ),
          ListTile(
            leading: const Icon(Icons.location_on), // Add location icon
            title: const Text('Fortunestown Supervalu Tallaght'),
            subtitle: const Text('Greenwich Mean Time'),
            trailing:
                selectedLocation == 'Fortunestown Supervalu Tallaght'
                    ? const Icon(Icons.check)
                    : null,
            onTap: () {
              Navigator.pop(context, 'Fortunestown Supervalu Tallaght');
            },
          ),
          ListTile(
            leading: const Icon(Icons.location_on), // Add location icon
            title: const Text('Killinarden Centra Tallaght'),
            subtitle: const Text('Greenwich Mean Time'),
            trailing:
                selectedLocation == 'Killinarden Centra Tallaght'
                    ? const Icon(Icons.check)
                    : null,
            onTap: () {
              Navigator.pop(context, 'Killinarden Centra Tallaght');
            },
          ),
          ListTile(
            leading: const Icon(Icons.location_on), // Add location icon
            title: const Text('Springfield Centra Tallaght'),
            subtitle: const Text('Greenwich Mean Time'),
            trailing:
                selectedLocation == 'Springfield Centra Tallaght'
                    ? const Icon(Icons.check)
                    : null,
            onTap: () {
              Navigator.pop(context, 'Springfield Centra Tallaght');
            },
          ),
        ],
      ),
    );
  }
}
