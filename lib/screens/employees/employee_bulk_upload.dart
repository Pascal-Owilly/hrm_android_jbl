import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:file_picker/file_picker.dart';
import '../../screens/constant.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Employee Bulk Upload',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const EmployeeBulkUploadScreen(),
    );
  }
}

class EmployeeBulkUploadScreen extends StatefulWidget {
  const EmployeeBulkUploadScreen({super.key});

  @override
  _EmployeeBulkUploadScreenState createState() => _EmployeeBulkUploadScreenState();
}

class _EmployeeBulkUploadScreenState extends State<EmployeeBulkUploadScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  PlatformFile? pickedFile;

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    if (result != null) {
      setState(() {
        pickedFile = result.files.first;
      });
    }
  }

  Future<void> _uploadFile() async {
    if (pickedFile != null) {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${BASE_URL}/upload'), // Replace with your API endpoint
      );

      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          pickedFile!.path!,
          filename: path.basename(pickedFile!.path!),
        ),
      );

      var response = await request.send();

      if (response.statusCode == 200) {
        print('File uploaded successfully');
      } else {
        print('File upload failed');
      }
    } else {
      print('No file selected');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Bulk Upload | JBL'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FormBuilder(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    'Employee Bulk Upload',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Divider(),
                const Text(
                  'Upload Excel File',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text('Please ensure your Excel file has the following columns:'),
                const SizedBox(height: 8),
                const Text(
                  'Example:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('First Name')),
                      DataColumn(label: Text('Last Name')),
                      DataColumn(label: Text('Email')),
                      DataColumn(label: Text('Username')),
                      DataColumn(label: Text('Phone Number')),
                      DataColumn(label: Text('Address')),
                      DataColumn(label: Text('Emergency Contact')),
                      DataColumn(label: Text('Gender')),
                      DataColumn(label: Text('Thumb')),
                    ],
                    rows: const [
                      DataRow(cells: [
                        DataCell(Text('John')),
                        DataCell(Text('Doe')),
                        DataCell(Text('john.doe@example.com')),
                        DataCell(Text('johndoe')),
                        DataCell(Text('+257123456789')),
                        DataCell(Text('123 Elm St')),
                        DataCell(Text('Jane Doe')),
                        DataCell(Text('Male')),
                        DataCell(Text('(optional)')),
                      ]),
                      DataRow(cells: [
                        DataCell(Text('Jane')),
                        DataCell(Text('Smith')),
                        DataCell(Text('jane.smith@example.com')),
                        DataCell(Text('janesmith')),
                        DataCell(Text('0987654321')),
                        DataCell(Text('456 Oak St')),
                        DataCell(Text('John Smith')),
                        DataCell(Text('Female')),
                        DataCell(Text('(optional image)')),
                      ]),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _pickFile,
                  child: const Text('Pick Excel File'),
                ),
                if (pickedFile != null) ...[
                  const SizedBox(height: 8),
                  Text('Picked file: ${pickedFile?.name}'),
                ],
                const SizedBox(height: 16),
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState?.saveAndValidate() ?? false) {
                        await _uploadFile();
                      } else {
                        print('Validation failed');
                      }
                    },
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.file_upload),
                        SizedBox(width: 8),
                        Text('Upload'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

