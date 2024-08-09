// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, use_key_in_widget_constructors, deprecated_member_use, library_private_types_in_public_api, use_build_context_synchronously, unnecessary_null_comparison

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FeedbackPage extends StatefulWidget {
  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _commentController = TextEditingController();

  // Add a variable to store the selected emoji
  int _selectedEmojiIndex = -1;

  // Add a variable to store the selected feedback type
  String _selectedFeedbackType = 'Feedback about Bus';
  final List<String> _feedbackTypes = [
    'Feedback about Bus',
    'Feedback about Service',
    'Feedback about Driver',
    'Feedback about Timing of Bus',
    'Others'
  ];

  late SupabaseClient _supabaseClient;

  @override
  void initState() {
    super.initState();
    _initializeSupabase();
  }

  Future<void> _initializeSupabase() async {
    _supabaseClient = SupabaseClient(
      'https://eybmkwawkpcjqlmkvsuv.supabase.co', // Replace with your Supabase URL
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImV5Ym1rd2F3a3BjanFsbWt2c3V2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTc4MDIxMzYsImV4cCI6MjAzMzM3ODEzNn0.LET1PqT-KD6Q_pz9_HRdXu75pZ8l2kfG8EGzpLIqLmw', // Replace with your Supabase Anon Key
    );
  }

Future<void> _submitData() async {
  final name = _nameController.text;
  final email = _emailController.text;
  final comments = _commentController.text;

  // Check if a feedback record with the same email address already exists
  final existingFeedback = await _supabaseClient
    .from('feedback')
    .select('id, email')
    .eq('email', email);

  if (existingFeedback.isNotEmpty) {
    // Update existing feedback record
    final updatedFeedback = {
      'name': name,
      'email': email,
      'comments': comments,
      'experience': _selectedEmojiIndex,
      'feedbacktype': _selectedFeedbackType,
    };
    await _supabaseClient
      .from('feedback')
      .update(updatedFeedback)
      .eq('id', existingFeedback[0]['id']);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Feedback updated successfully!')),
    );
  } else {
    // Insert new feedback record
    final response = await _supabaseClient
      .from('feedback')
      .insert({
        'name': name,
        'email': email,
        'comments': comments,
        'experience': _selectedEmojiIndex,
        'feedbacktype': _selectedFeedbackType,
      });

    if (response.error == null) {
      // Data successfully inserted
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Data submitted successfully!')),
      );
    } else {
      // An error occurred
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit data: ${response.error!.message}')),
      );
    }
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 72, 80, 155),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ), // Set arrow color to white
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              // Commenting out the backgroundImage line
              backgroundImage: AssetImage('assets/images/bar.png'),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Feedback Form',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 41, 41, 41),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Name',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Enter your name',
                  labelStyle: TextStyle(color: Colors.blueAccent),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blueAccent),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blueAccent),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Email',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Enter your email',
                  labelStyle: TextStyle(color: Colors.blueAccent),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blueAccent),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blueAccent),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Feedback Type',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _selectedFeedbackType,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: Colors.blueAccent),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: Colors.blueAccent),
                  ),
                ),
                items: _feedbackTypes.map((String feedbackType) {
                  return DropdownMenuItem<String>(
                    value: feedbackType,
                    child: Text(feedbackType),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedFeedbackType = newValue!;
                  });
                },
              ),
              SizedBox(height: 20),
              Text(
                'Comments',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _commentController,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: 'Enter your comments',
                  labelStyle: TextStyle(color: Colors.blueAccent),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blueAccent),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blueAccent),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Rate Your Experience',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.sentiment_very_dissatisfied,
                        size: 40, color: _selectedEmojiIndex == 0 ? Colors.red : Colors.grey),
                    onPressed: () => setState(() => _selectedEmojiIndex = 0),
                  ),
                  IconButton(
                    icon: Icon(Icons.sentiment_dissatisfied,
                        size: 40, color: _selectedEmojiIndex == 1 ? Colors.orange : Colors.grey),
                    onPressed: () => setState(() => _selectedEmojiIndex = 1),
                  ),
                  IconButton(
                    icon: Icon(Icons.sentiment_neutral,
                        size: 40, color: _selectedEmojiIndex == 2 ? Colors.yellow : Colors.grey),
                    onPressed: () => setState(() => _selectedEmojiIndex = 2),
                  ),
                  IconButton(
                    icon: Icon(Icons.sentiment_satisfied,
                        size: 40, color: _selectedEmojiIndex == 3 ? Colors.lightGreen : Colors.grey),
                    onPressed: () => setState(() => _selectedEmojiIndex = 3),
                  ),
                  IconButton(
                    icon: Icon(Icons.sentiment_very_satisfied,
                        size: 40, color: _selectedEmojiIndex == 4 ? Colors.green : Colors.grey),
                    onPressed: () => setState(() => _selectedEmojiIndex = 4),
                  ),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitData,
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith<Color>(
                    (Set<MaterialState> states) {
                      if (states.contains(MaterialState.disabled)) {
                        return const Color.fromARGB(
                            255, 0, 0, 0); // Disabled button color
                      }
                      return Color.fromARGB(
                          255, 232, 233, 235); // Enabled button color
                    },
                  ),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50.0),
                    ),
                  ),
                  padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                    EdgeInsets.symmetric(vertical: 15),
                  ),
                  // Add elevation to make button more prominent
                  elevation: MaterialStateProperty.resolveWith<double>(
                    (Set<MaterialState> states) {
                      return 10; // Elevation value
                    },
                  ),
                ),
                child: Text(
                  'Submit Your Feedback',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}