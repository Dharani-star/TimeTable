import 'dart:convert';
// ignore: deprecated_member_use, avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Course Selection',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Poppins',
      ),
      home: const CodeEntryScreen(),
    );
  }
}

// Mock storage for user choices (used for the admin page)
List<Map<String, dynamic>> savedUserChoices = [];

class CodeEntryScreen extends StatefulWidget {
  const CodeEntryScreen({super.key});

  @override
  _CodeEntryScreenState createState() => _CodeEntryScreenState();
}

class _CodeEntryScreenState extends State<CodeEntryScreen> {
  final TextEditingController _codeController = TextEditingController();

  void _goToCourseSelection() {
    String code = _codeController.text;

    // Check if the code is valid (5 digits, numeric, and starts with "5")
    if (code.length != 5 || int.tryParse(code) == null || !code.startsWith("5")) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Invalid Code"),
            content: const Text(
              "Please enter your code",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
      return;
    }

    // Check if the code exists in savedUserChoices
    bool codeExists = savedUserChoices.any((userData) => userData['user'] == code);

    if (codeExists) {
      // Show a warning dialog if the code is already in admin page
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Access Denied"),
            content: const Text(
              "Course Selection for this code is completed. Please contact the administrator.",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
      return;
    }

    // Determine maxCourses and maxPerCategory based on code prefix
    int maxCourses = code.startsWith("50") || code.startsWith("51") ? 5 : 15;
    int maxPerCategory = code.startsWith("50") || code.startsWith("51") ? 1 : 3;

    // Navigate to CourseSelectionScreen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CourseSelectionScreen(
          code: code,
          maxCourses: maxCourses,
          maxPerCategory: maxPerCategory,
          preloadedChoices: null,
        ),
      ),
    );
  }

  void _goToAdminAccess() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AdminAccessScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Code Entry"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Enter your 5-digit code:",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              controller: _codeController,
              maxLength: 5,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Code",
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _goToCourseSelection,
            child: const Text("Proceed"),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _goToAdminAccess,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.shield, size: 28),
      ),
    );
  }
}

// Admin Access Screen
class AdminAccessScreen extends StatelessWidget {
  const AdminAccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController adminCodeController = TextEditingController();

    void validateAdminCode() {
      if (adminCodeController.text == "1281") {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AdminPage(),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Invalid admin code!"),
          ),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Admin Access")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Enter Admin Code",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: adminCodeController,
                decoration: const InputDecoration(
                  labelText: "Admin Code",
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: validateAdminCode,
                child: const Text("Enter"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Admin Page
class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Admin Page"),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, // Button color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20), // Rounded rectangle
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Small button
              ),
              onPressed: () {
                generateAndDownloadCSV();
              },
              child: const Text(
                "Print",
                style: TextStyle(
                  color: Colors.white, // Text color
                  fontSize: 14, // Small but readable text
                ),
              ),
            ),
          ],
        ),
      ),
      body: ListView.builder(
        itemCount: savedUserChoices.length,
        itemBuilder: (context, index) {
          final userData = savedUserChoices[index];
          final code = userData['user'] ?? 'Unknown';
          final choices = userData['choices'] as List<dynamic>;
          final timestamp = userData['timestamp'] ?? 'Unknown';
          final preferredCategory = userData['preferredCategory'] ?? 'None';

          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              title: Text("User ${index + 1}: $code"),
              subtitle: Text(
                "Total Choices: ${choices.length}\n"
                "Saved At: $timestamp",
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // View Button
                  IconButton(
                    icon: const Icon(Icons.visibility, color: Colors.green),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text("User Details"),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Code: $code",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Preferred Category: $preferredCategory",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Selected Courses (${choices.length}):",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ...choices.asMap().entries.map((entry) {
                                  int serialNumber = entry.key + 1;
                                  final courseDetails =
                                      entry.value as Map<String, dynamic>;
                                  final course =
                                      courseDetails['subject'] ?? 'Unknown';
                                  final category =
                                      courseDetails['category'] ?? 'Unknown';
                                  return Text(
                                      "$serialNumber. $course ( $category )");
                                }),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text("Close"),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                  // Remove Button
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      savedUserChoices.removeAt(index);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("User data removed.")),
                      );
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const AdminPage()),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void generateAndDownloadCSV() {
    // Create the CSV header
    List<String> headers = ["Code", "Preferred Category"];
    for (int i = 1; i <= 15; i++) {
      headers.add("Course $i");
    }

    // Build the rows
    List<List<String>> rows = [];
    for (final userData in savedUserChoices) {
      String code = userData['user'] ?? 'Unknown';
      String preferredCategory = userData['preferredCategory'] ?? 'None';
      List<dynamic> choices = userData['choices'] as List<dynamic>;

      // Start the row with Code and Preferred Category
      List<String> row = [code, preferredCategory];

      // Add courses to the row
      for (final choice in choices) {
        String subject = choice['subject'] ?? 'Unknown';
        row.add(subject);
      }

      // Fill the remaining columns with empty strings if less than 15 courses
      while (row.length < headers.length) {
        row.add('');
      }

      rows.add(row);
    }

    // Convert rows to CSV format
    String csvContent = headers.join(",") + "\n";
    for (final row in rows) {
      csvContent += row.join(",") + "\n";
    }

    // Trigger download
    final bytes = utf8.encode(csvContent);
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..target = 'blank'
      ..download = "user_data.csv"
      ..click();
    html.Url.revokeObjectUrl(url);
  }
}

class CourseSelectionScreen extends StatefulWidget {
  final String code;
  final int maxCourses;
  final int maxPerCategory;

  const CourseSelectionScreen({
    super.key,
    required this.code,
    required this.maxCourses,
    required this.maxPerCategory,
    required preloadedChoices,
  });

  @override
  _CourseSelectionScreenState createState() => _CourseSelectionScreenState();
}

// The CourseSelectionScreen implementation remains unchanged
// Paste your existing CourseSelectionScreen class here
// ...
class _CourseSelectionScreenState extends State<CourseSelectionScreen> {
  late Map<String, List<String>> coursesByCategory;
  late Map<String, bool> selectedCourses;
  late Map<String, String> courseCategoryMap;
  late List<String> selectedCourseList;
  String _preferredCategory = "None";
  bool saveButtonEnabled = false;
  bool printButtonEnabled = false;
  bool selectionLocked = false;
  bool isFullyDisabled = false;

  @override
  void initState() {
    super.initState();
    coursesByCategory = {
      "Artificial Intelligence": [
        "Introduction to AI",
        "Neural Networks",
        "Natural Language Processing",
        "AI Ethics",
        "AI in Robotics",
        "AI for Cybersecurity"
      ],
      "Machine Learning": [
        "Supervised Learning",
        "Unsupervised Learning",
        "Reinforcement Learning",
        "Deep Learning",
        "ML in Healthcare",
        "ML for Autonomous Systems"
      ],
      "Circuit Theory": [
        "Circuit Analysis",
        "Digital Circuits",
        "Analog Circuits",
        "Power Systems",
        "Circuit Simulation",
        "Circuit Optimization"
      ],
      "Robotics": [
        "Introduction to Robotics",
        "Robot Kinematics",
        "Robot Dynamics",
        "Control Systems",
        "Mobile Robotics",
        "Humanoid Robotics"
      ],
      "Information Technology": [
        "Introduction to IT",
        "Database Systems",
        "Computer Networks",
        "Cybersecurity Essentials",
        "Cloud Computing",
        "IT Project Management"
      ]
    };

    selectedCourses = {};
    selectedCourseList = [];
    courseCategoryMap = {};

    for (var category in coursesByCategory.keys) {
      for (var course in coursesByCategory[category]!) {
        selectedCourses[course] = false;
        courseCategoryMap[course] = category;
      }
    }
  }

  void _toggleCourseSelection(String course) {
    if (selectionLocked || isFullyDisabled) return;

    setState(() {
      String category = courseCategoryMap[course]!;
      int categoryCount = selectedCourseList
          .where((c) => courseCategoryMap[c] == category)
          .length;

      if (selectedCourses[course] == true) {
        selectedCourses[course] = false;
        selectedCourseList.remove(course);
      } else {
        bool canAdd = selectedCourseList.length < widget.maxCourses &&
            (categoryCount < widget.maxPerCategory ||
                (_preferredCategory == category &&
                    categoryCount < widget.maxPerCategory + 1));

        if (canAdd) {
          selectedCourses[course] = true;
          selectedCourseList.add(course);
        }
      }

      _updateButtons();
    });
  }

  void _updateButtons() {
    saveButtonEnabled = selectedCourseList.isNotEmpty;
  }

  void _saveSelection() {
    if (isFullyDisabled) return;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Confirm Selection"),
          content: Text(
            "You have selected ${selectedCourseList.length}/${widget.maxCourses} courses. Do you wish to continue?",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text("No"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog

                // Save each course with its category
                final savedChoices = selectedCourseList.map((course) {
                  return {
                    "subject": course,
                    "category": courseCategoryMap[course],
                  };
                }).toList();

                // Add to savedUserChoices
                savedUserChoices.add({
                  "user": widget.code,
                  "choices": savedChoices,
                  "preferredCategory":
                      _preferredCategory, // Save preferred category
                  "timestamp":
                      DateFormat('yyyy-MM-dd – kk:mm').format(DateTime.now()),
                });

                // Disable further actions
                setState(() {
                  isFullyDisabled = true;
                  saveButtonEnabled = false;
                  printButtonEnabled = true;
                  selectionLocked = true;
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text("Your selection has been saved.")),
                );
              },
              child: const Text("Yes"),
            ),
          ],
        );
      },
    );
  }

  void _printSelection() {
    final csvData = [
      ["Sl No.", "Course", "Category"],
      ...selectedCourseList.asMap().entries.map((entry) {
        int index = entry.key + 1;
        String course = entry.value;
        String category = courseCategoryMap[course]!;
        return [index, course, category];
      })
    ];

    final csvContent = const ListToCsvConverter().convert(csvData);
    final bytes = utf8.encode(csvContent);
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);

    final anchor = html.AnchorElement(href: url)
      ..setAttribute("download", "selected_courses.csv")
      ..click();

    html.Url.revokeObjectUrl(url);

    setState(() {
      isFullyDisabled = true;
    });
  }

  void _resetSelection() {
    if (isFullyDisabled) return;
    setState(() {
      for (var course in selectedCourses.keys) {
        selectedCourses[course] = false;
      }
      selectedCourseList.clear();
      saveButtonEnabled = false;
      printButtonEnabled = false;
      selectionLocked = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Welcome, User ${widget.code}"),
      ),
      body: Row(
        children: [
          Expanded(
            flex: 2,
            child: ListView(
              children: coursesByCategory.entries.map((entry) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(entry.key,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    ...entry.value.map((course) {
                      return CheckboxListTile(
                        title: Text(course),
                        value: selectedCourses[course] ?? false,
                        onChanged: isFullyDisabled
                            ? null
                            : (bool? value) {
                                _toggleCourseSelection(course);
                              },
                      );
                    }),
                  ],
                );
              }).toList(),
            ),
          ),
          Expanded(
            flex: 1,
            child: Column(
              children: [
                Text(
                  "Selected Courses: ${selectedCourseList.length}/${widget.maxCourses}",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                DropdownButton<String>(
                  value: _preferredCategory,
                  items: [
                    "None",
                    "Artificial Intelligence",
                    "Machine Learning",
                    "Circuit Theory",
                    "Robotics",
                    "Information Technology"
                  ].map((category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: isFullyDisabled
                      ? null
                      : (value) {
                          setState(() {
                            _preferredCategory = value!;
                          });
                        },
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 300,
                  child: ListView(
                    children: [
                      const ListTile(
                        title: Text("Sl No."),
                        subtitle: Text("Course"),
                        trailing: Text("Category"),
                      ),
                      ...selectedCourseList.asMap().entries.map((entry) {
                        int index = entry.key + 1;
                        String course = entry.value;
                        String category = courseCategoryMap[course]!;
                        return ListTile(
                          title: Text(index.toString()),
                          subtitle: Text(course),
                          trailing: Text(category),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: printButtonEnabled ? _printSelection : null,
                      child: const Text("Print"),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: saveButtonEnabled ? _saveSelection : null,
                      child: const Text("Save"),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: isFullyDisabled ? null : _resetSelection,
                      child: const Text("Reset"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ListToCsvConverter {
  const ListToCsvConverter();

  String convert(List<List<dynamic>> data) {
    return data.map((row) {
      return row.map((field) {
        if (field is String && field.contains(',')) {
          return '"$field"';
        }
        return field.toString();
      }).join(',');
    }).join('\n');
  }
}