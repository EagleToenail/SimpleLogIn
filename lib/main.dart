import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_login/home.dart';
import 'package:http/http.dart' as http;
import 'package:simple_login/store.dart';
import 'dart:convert';
import 'toast.dart';
import 'const.dart';

final GlobalKey<MyAppState> myAppKey = GlobalKey<MyAppState>();

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => AppStore(),
      child: MyApp(key: myAppKey),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // 👈 just add this
    );
  }

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  Map<String, dynamic> schedule = <String, dynamic>{
    "id": '',
    "user": {"id": '', "preferredName": ''},
    "location": {"id": '', "area": ''},
    "startTime": DateTime.now(),
    "endTime": DateTime.now(),
    "status": '',
  };

  @override
  void initState() {
    super.initState();
    // loadData();
  }

  void loadData() {
    print("🔃 Loading data...");
    context.read<AppStore>().loadPeople();
    context.read<AppStore>().loadLocations();
  }

  void updateSchedule(Map<String, dynamic> newSchedule) {
    context.read<AppStore>().updateSchedule(newSchedule);
  }

  void clearSchedule() {
    context.read<AppStore>().clearSchedule();
  }

  void setLoggedInUser(UserInfo user) {
    context.read<AppStore>().setLoggedInUser(
      userID: user.userID,
      username: user.username,
      preferredName: user.preferredName,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Login',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 52, 140, 241),
        ),
      ),
      home: const LoginPage(),
      debugShowCheckedModeBanner: false, // 👈 Add this line here
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _handleLogin() async {
    final String email = _emailController.text;
    final String password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      Toast.show(context, 'Please fill in all fields', type: ToastType.info);
      return;
    }

    print("✋ handle login");

    sendMessageToServer(context, email, password);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image fills the entire screen
          Positioned.fill(
            child: Image.asset(
              'assets/bg.png', // Your background image path
              fit: BoxFit.cover, // Cover the entire area without distortion
            ),
          ),

          // Foreground content centered with padding
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min, // Wrap content vertically
                children: <Widget>[
                  SizedBox(height: 250),
                  CustomTextField(
                    controller: _emailController,
                    labelText: 'Email',
                    hintText: 'Enter your email',
                  ),
                  SizedBox(height: 4), // Spacing between fields
                  PasswordField(
                    controller: _passwordController,
                    labelText: 'Password',
                    hintText: 'Enter your password',
                  ),
                  SizedBox(height: 12), // Spacing before button
                  MyElevatedButton(
                    buttonText: 'LOG IN',
                    onPressed: _handleLogin,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  final String labelText;
  final String hintText;
  final TextEditingController controller;

  const CustomTextField({
    Key? key,
    required this.labelText,
    required this.hintText,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        vertical: 8.0,
        horizontal: 16.0,
      ), // Adjust the margin as needed
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.grey[600], // Light grey hint text
            fontSize: 14, // Slightly smaller hint text for a modern feel
          ),
          labelStyle: TextStyle(
            color: Colors.black87,
            fontWeight:
                FontWeight
                    .w500, // Slightly lighter font weight for a modern look
            fontSize: 16, // Adjust font size for a better balance
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.blueAccent, // Subtle blue accent color for focus
              width: 2.0,
            ),
            borderRadius: BorderRadius.circular(
              12.0,
            ), // Rounded corners for a softer look
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color:
                  Colors
                      .grey[300]!, // Lighter grey color when the field is enabled
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(12.0),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.red, // Error color for validation feedback
              width: 2.0,
            ),
            borderRadius: BorderRadius.circular(12.0),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.redAccent, // Focused error color
              width: 2.0,
            ),
            borderRadius: BorderRadius.circular(12.0),
          ),
          contentPadding: EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 20,
          ), // Padding inside the text field
          filled: true,
          fillColor:
              Colors.white, // Slightly subtle background color for the field
          isDense: true, // Reduces height for a more compact field
        ),
      ),
    );
  }
}

class MyElevatedButton extends StatelessWidget {
  final String buttonText; // Variable to hold the text for the button
  final VoidCallback onPressed; // Callback function for button press
  // Constructor to pass the text dynamically
  MyElevatedButton({required this.buttonText, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(
        buttonText, // Use the variable for the button's text
        style: TextStyle(
          color: Colors.white, // Text color
          fontSize: 16, // Font size
          fontWeight: FontWeight.bold, // Bold text
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor:
            Colors
                .blueAccent, // Background color (use backgroundColor instead of primary)
        elevation: 0, // Shadow elevation
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10), // Rounded corners
        ),
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12), // Padding
      ),
    );
  }
}

class PasswordField extends StatefulWidget {
  final String labelText;
  final String hintText;
  final TextEditingController controller;

  const PasswordField({
    Key? key,
    required this.labelText,
    required this.hintText,
    required this.controller,
  }) : super(key: key);

  @override
  _PasswordFieldState createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscureText = true; // Controls the visibility of the password text

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        vertical: 8.0,
        horizontal: 16.0,
      ), // Adjust the margin as needed
      child: TextFormField(
        controller: widget.controller,
        obscureText: _obscureText,
        decoration: InputDecoration(
          labelText: widget.labelText,
          hintText: widget.hintText,
          hintStyle: TextStyle(
            color: Colors.grey[600], // Light grey hint text
            fontSize: 14, // Slightly smaller hint text for a modern feel
          ),
          labelStyle: TextStyle(
            color: Colors.black87,
            fontWeight:
                FontWeight
                    .w500, // Slightly lighter font weight for a modern look
            fontSize: 16, // Adjust font size for a better balance
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.blueAccent, // Subtle blue accent color for focus
              width: 2.0,
            ),
            borderRadius: BorderRadius.circular(
              12.0,
            ), // Rounded corners for a softer look
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color:
                  Colors
                      .grey[300]!, // Lighter grey color when the field is enabled
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(12.0),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.red, // Error color for validation feedback
              width: 2.0,
            ),
            borderRadius: BorderRadius.circular(12.0),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.redAccent, // Focused error color
              width: 2.0,
            ),
            borderRadius: BorderRadius.circular(12.0),
          ),
          contentPadding: EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 20,
          ), // Padding inside the text field
          filled: true,
          fillColor:
              Colors.white, // Slightly subtle background color for the field
          isDense: true, // Reduces height for a more compact field
          suffixIcon: IconButton(
            icon: Icon(
              _obscureText ? Icons.visibility_off : Icons.visibility,
              color: Colors.grey[600],
            ),
            onPressed: () {
              setState(() {
                _obscureText = !_obscureText; // Toggle the password visibility
              });
            },
          ),
        ),
      ),
    );
  }
}

Future<void> sendMessageToServer(
  BuildContext context,
  email,
  String password,
) async {
  final requestBody = {'email': email, 'password': password};

  final url = Uri.parse(LOGIN_URL);

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(requestBody),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);

    // * Get User and Location data
    myAppKey.currentState?.loadData();

    print("✅ Login Success!");
    if (data['success']) {
      myAppKey.currentState?.setLoggedInUser(UserInfo.fromJson(data['user']));

      Toast.show(context, 'Login successful', type: ToastType.success);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } else {
      Toast.show(context, data['message'], type: ToastType.error);
    }
  } else {
    print('Error: ${response.statusCode}');
  }
}
