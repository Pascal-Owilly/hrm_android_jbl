import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../screens/constant.dart';

class NewClientScreen extends StatefulWidget {
  const NewClientScreen({super.key});

  @override
  _NewClientScreenState createState() => _NewClientScreenState();
}

class _NewClientScreenState extends State<NewClientScreen> {
  final _formKey = GlobalKey<FormBuilderState>();

Future<void> _submitForm(Map<String, dynamic> formData) async {
  final response = await http.post(
    Uri.parse('${BASE_URL}/api/clients/'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(formData),
  );

  if (response.statusCode == 200) {
    print('Client added successfully');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Client added successfully')),
    );
    Navigator.pushNamed(context, '/list_clients');
  } else {
    final errorResponse = jsonDecode(response.body);
    final errorMessage = errorResponse['message'] ?? 'Failed to add client';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(errorMessage)),
    );
    print('Failed to add client');
  }
}

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('New Client | JBL'),
    ),
    body: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FormBuilder(
          key: _formKey,
          child: Column(
            children: [
              Card(
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Header
                      const Center(
                        child: Text(
                          'New Client',
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Divider(),
                      FormBuilderTextField(
                        name: 'name',
                        decoration: const InputDecoration(
                          labelText: 'Name',
                        ),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
                        ]),
                      ),
                      FormBuilderTextField(
                        name: 'branch',
                        decoration: const InputDecoration(
                          labelText: 'Branch',
                        ),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
                        ]),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState?.saveAndValidate() ?? false) {
                            final formData = _formKey.currentState?.value;
                            _submitForm(formData!);
                          } else {
                            print('Validation failed');
                          }
                        },
                        child: const Text('Add Client'),
                      ),
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

