import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:http/http.dart' as http;
import '../../screens/constant.dart';

class NewEmployeeScreen extends StatefulWidget {
  const NewEmployeeScreen({super.key});

  @override
  _NewEmployeeScreenState createState() => _NewEmployeeScreenState();
}

class _NewEmployeeScreenState extends State<NewEmployeeScreen> {
  final _formKey = GlobalKey<FormBuilderState>();

  Future<void> _submitForm(Map<String, dynamic> formData) async {
    final response = await http.post(
      Uri.parse('${BASE_URL}/employees'), // Replace with your API endpoint
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: formData,
    );

    if (response.statusCode == 200) {
      print('Employee added successfully');
    } else {
      print('Failed to add employee');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Employee | JBL'),
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
                            'New Employee',
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Divider(),
                        FormBuilderTextField(
                          name: 'first_name',
                          decoration: const InputDecoration(
                            labelText: 'First Name',
                          ),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(),
                          ]),
                        ),
                        FormBuilderTextField(
                          name: 'last_name',
                          decoration: const InputDecoration(
                            labelText: 'Last Name',
                          ),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(),
                          ]),
                        ),
                        FormBuilderTextField(
                          name: 'email',
                          decoration: const InputDecoration(
                            labelText: 'Email',
                          ),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(),
                            FormBuilderValidators.email(),
                          ]),
                        ),
                        FormBuilderTextField(
                          name: 'mobile',
                          decoration: const InputDecoration(
                            labelText: 'Mobile',
                          ),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(),
                            FormBuilderValidators.numeric(),
                          ]),
                        ),
                        FormBuilderDropdown(
                          name: 'gender',
                          decoration: const InputDecoration(
                            labelText: 'Gender',
                          ),
                          items: ['Male', 'Female', 'Other']
                              .map((gender) => DropdownMenuItem(
                                    value: gender,
                                    child: Text(gender),
                                  ))
                              .toList(),
                          validator: FormBuilderValidators.required(),
                        ),
                        FormBuilderTextField(
                          name: 'address',
                          decoration: const InputDecoration(
                            labelText: 'Address',
                          ),
                          validator: FormBuilderValidators.required(),
                        ),
                        FormBuilderTextField(
                          name: 'emergency',
                          decoration: const InputDecoration(
                            labelText: 'Emergency Contact',
                          ),
                          validator: FormBuilderValidators.required(),
                        ),
                        FormBuilderTextField(
                          name: 'thumb',
                          decoration: const InputDecoration(
                            labelText: 'Thumbnail',
                          ),
                          validator: FormBuilderValidators.required(),
                        ),
                        FormBuilderTextField(
                          name: 'username',
                          decoration: const InputDecoration(
                            labelText: 'Username',
                          ),
                          validator: FormBuilderValidators.required(),
                        ),
                        FormBuilderTextField(
                          name: 'password1',
                          decoration: const InputDecoration(
                            labelText: 'Password',
                          ),
                          obscureText: true,
                          validator: FormBuilderValidators.required(),
                        ),
                        FormBuilderTextField(
                          name: 'password2',
                          decoration: const InputDecoration(
                            labelText: 'Confirm Password',
                          ),
                          obscureText: true,
                          validator: FormBuilderValidators.required(),
                        ),
                        FormBuilderTextField(
                          name: 'client',
                          decoration: const InputDecoration(
                            labelText: 'Client',
                          ),
                          validator: FormBuilderValidators.required(),
                        ),
                        FormBuilderTextField(
                          name: 'privileges',
                          decoration: const InputDecoration(
                            labelText: 'Privileges',
                          ),
                          validator: FormBuilderValidators.required(),
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
                          child: const Text('Add Employee'),
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

