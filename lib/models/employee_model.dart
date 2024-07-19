
class Employee {
  final String date;
  final String firstIn;
  final String lastOut;
  final String name;

  Employee({
    required this.date,
    required this.firstIn,
    required this.lastOut,
    required this.name,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      date: json['date'],
      firstIn: json['first_in'],
      lastOut: json['last_out'],
      name: json['name'],
    );
  }
}
