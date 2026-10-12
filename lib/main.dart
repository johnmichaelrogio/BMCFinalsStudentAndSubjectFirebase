import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();


  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );


  runApp(const MyApp());
}


// MAIN APP


class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FirstScreen(),
    );
  }
}


// SCREEN 1: USER REGISTRATION


class FirstScreen extends StatefulWidget {
  const FirstScreen({super.key});


  @override
  State<FirstScreen> createState() => _FirstScreenState();
}


class _FirstScreenState extends State<FirstScreen> {
  final nameController = TextEditingController();
  final sectionController = TextEditingController();
  final courseController = TextEditingController();


  @override
  void dispose() {
    nameController.dispose();
    sectionController.dispose();
    courseController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Registration'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name(LastName, FirstName Initial)',
                border: OutlineInputBorder(),
              ),
            ),
            
            const SizedBox(height: 12),


            TextField(
              controller: sectionController,
              decoration: const InputDecoration(
                labelText: 'Section',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),


            TextField(
              controller: courseController,
              decoration: const InputDecoration(
                labelText: 'Course',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),


            ElevatedButton(
              onPressed: () {
                if (nameController.text.trim().isEmpty ||
                    sectionController.text.trim().isEmpty ||
                    courseController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill in all fields'),
                    ),
                  );
                  return;
                }


                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SubjectScreen(
                      name: nameController.text.trim(),
                      section: sectionController.text.trim(),
                      course: courseController.text.trim(),
                    ),
                  ),
                );
              },
              child: const Text('Next'),
            ),
          ],
        ),
      ),
    );
  }
}


// SCREEN 2: SUBJECT ENROLLMENT


class SubjectScreen extends StatefulWidget {
  final String name;
  final String section;
  final String course;


  const SubjectScreen({
    super.key,
    required this.name,
    required this.section,
    required this.course,
  });


  @override
  State<SubjectScreen> createState() => _SubjectScreenState();
}


class _SubjectScreenState extends State<SubjectScreen> {
  final List<TextEditingController> subjectControllers = [];
  final List<TextEditingController> startControllers = [];
  final List<TextEditingController> endControllers = [];


  @override
  void initState() {
    super.initState();
    addSubject();
  }


  void addSubject() {
    subjectControllers.add(TextEditingController());
    startControllers.add(TextEditingController());

  }


  @override
  void dispose() {
    for (final controller in subjectControllers) {
      controller.dispose();
    }
    for (final controller in startControllers) {
      controller.dispose();
    }
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subject Enrollment'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('Add subjects and their class times'),
            const SizedBox(height: 16),


            ...List.generate(subjectControllers.length, (index) {
              return Column(
                children: [
                  Text('Subject ${index + 1}'),



                  TextField(
                    controller: subjectControllers[index],
                    decoration: const InputDecoration(
                      labelText: 'Subject',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),


                  TextField(
                    controller: startControllers[index],
                    decoration: const InputDecoration(
                      labelText: 'Start Time (e.g. 7:30 AM - 9:30 AM)',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: subjectControllers.length == 1
                        ? null
                        : () {
                            setState(() {
                              subjectControllers.removeAt(index).dispose();
                              startControllers.removeAt(index).dispose();
                            });
                          },
                    child: const Text('Remove Subject'),
                  ),
                  


                  const SizedBox(height: 16),
                ],
              );
            }),


            ElevatedButton(
              onPressed: () {
                setState(() {
                  addSubject();
                });
              },
              child: const Text('Add Subject'),
            ),

            const SizedBox(height: 20),


            ElevatedButton(
              onPressed: () {
                bool incomplete = false;


                for (int i = 0; i < subjectControllers.length; i++) {
                  if (subjectControllers[i].text.trim().isEmpty ||
                      startControllers[i].text.trim().isEmpty) {
                    incomplete = true;
                    break;
                  }
                }


                if (incomplete) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Please complete all subjects and time',
                      ),
                    ),
                  );
                  return;
                }


                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReviewScreen(
                      name: widget.name,
                      section: widget.section,
                      course: widget.course,
                      subjects: List.generate(
                        subjectControllers.length,
                        (i) => {
                          'subject': subjectControllers[i].text.trim(),
                          'start': startControllers[i].text.trim(),
                        },
                      ),
                    ),
                  ),
                );
              },
              child: const Text('Next'),
            ),
          ],
        ),
      ),
    );
  }
}


// SCREEN 3: SUBJECT VERIFICATION


class ReviewScreen extends StatefulWidget {
  final String name;
  final String section;
  final String course;
  final List<Map<String, String>> subjects;


  const ReviewScreen({
    super.key,
    required this.name,
    required this.section,
    required this.course,
    required this.subjects,
  });


  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}


class _ReviewScreenState extends State<ReviewScreen> {
  bool isSaving = false;
  bool isSaved = false;


  Future<void> saveData() async {
    if (isSaving || isSaved) return;


    setState(() {
      isSaving = true;
    });


    try {
      await FirebaseFirestore.instance.collection('enrollments').add({
        'name': widget.name,
        'section': widget.section,
        'course': widget.course,
        'subjects': widget.subjects,
        'createdAt': FieldValue.serverTimestamp(),
      });


      if (!mounted) return;


      setState(() {
        isSaved = true;
      });


      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data saved successfully!'),
        ),
      );
    } catch (e) {
      if (!mounted) return;


      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving data: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subject Verification'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${widget.name}'),
            Text('Section: ${widget.section}'),
            Text('Course: ${widget.course}'),


            const SizedBox(height: 20),


            const Text('Your Subjects'),


            ...List.generate(widget.subjects.length, (index) {
              final subject = widget.subjects[index];


              return ListTile(
                title: Text(
                  '${index + 1}. ${subject['subject']}',
                ),
                subtitle: Text(
                  'Time: ${subject['start']} - ${subject['end']}',
                ),
              );
            }),


            const SizedBox(height: 20),


            ElevatedButton(
              onPressed: (isSaving || isSaved) ? null : saveData,
              child: Text(
                isSaving
                    ? 'Saving...'
                    : isSaved
                        ? 'Saved Successfully'
                        : 'Save to Firebase',
              ),
            ),


            const SizedBox(height: 10),


            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}