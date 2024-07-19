
class User {
  final int id;
  String username;
  String firstName;
  String lastName;
  String email;
  String thumb;
  String phoneNumber;
  String address;
  String client;
  String clockinPrivileges;
  String emergencyContact;
  String gender;
  List<String> clientOptions;
  List<String> clockinPrivilegesOptions;

  User({
    required this.id,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.thumb,
    required this.phoneNumber,
    required this.address,
    required this.client,
    required this.clockinPrivileges,
    required this.emergencyContact,
    required this.gender,
    required this.clientOptions,
    required this.clockinPrivilegesOptions,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email'],
      thumb: json['thumb'] ?? 'https://example.com/default_profile.png',
      phoneNumber: json['phone_number'] ?? '',
      address: json['address'] ?? '',
      client: json['client'] ?? '',
      clockinPrivileges: json['clockin_privileges'] ?? '',
      emergencyContact: json['emergency_contact'] ?? '',
      gender: json['gender'] ?? '',
      clientOptions: (json['client_options'] ?? []).cast<String>(),
      clockinPrivilegesOptions: (json['clockin_privileges_options'] ?? []).cast<String>(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'thumb': thumb,
      'phone_number': phoneNumber,
      'address': address,
      'client': client,
      'clockin_privileges': clockinPrivileges,
      'emergency_contact': emergencyContact,
      'gender': gender,
      'client_options': clientOptions,
      'clockin_privileges_options': clockinPrivilegesOptions,
    };
  }

  String getUsername() {
    return username;
  }

  void setUsername(String value) {
    username = value;
  }

  String getFirstName() {
    return firstName;
  }

  void setFirstName(String value) {
    firstName = value;
  }

  String getLastName() {
    return lastName;
  }

  void setLastName(String value) {
    lastName = value;
  }

  String getEmail() {
    return email;
  }

  void setEmail(String value) {
    email = value;
  }

  String getThumb() {
    return thumb;
  }

  void setThumb(String value) {
    thumb = value;
  }

  String getPhoneNumber() {
    return phoneNumber;
  }

  void setPhoneNumber(String value) {
    phoneNumber = value;
  }

  String getAddress() {
    return address;
  }

  void setAddress(String value) {
    address = value;
  }

  String getClient() {
    return client;
  }

  void setClient(String value) {
    client = value;
  }

  String getClockinPrivileges() {
    return clockinPrivileges;
  }

  void setClockinPrivileges(String value) {
    clockinPrivileges = value;
  }

  String getEmergencyContact() {
    return emergencyContact;
  }

  void setEmergencyContact(String value) {
    emergencyContact = value;
  }

  String getGender() {
    return gender;
  }

  void setGender(String value) {
    gender = value;
  }

  List<String> getClientOptions() {
    return clientOptions;
  }

  void setClientOptions(List<String> value) {
    clientOptions = value;
  }

  List<String> getClockinPrivilegesOptions() {
    return clockinPrivilegesOptions;
  }

  void setClockinPrivilegesOptions(List<String> value) {
    clockinPrivilegesOptions = value;
  }
}

