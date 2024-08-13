import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'expense.dart';
import 'add_expense_dialog.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

void main() {
  runApp(ExpenseTrackerApp());
}

class ExpenseTrackerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ExpenseListScreen(),
    );
  }
}


class PredictionGraphScreen extends StatelessWidget {
  final Uint8List imageBytes;

  PredictionGraphScreen({required this.imageBytes});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Prediction Graph')),
      body: Center(
        child: imageBytes.isNotEmpty
            ? Image.memory(imageBytes)
            : Text('No graph to display'),
      ),
    );
  }
}

class ExpenseListScreen extends StatefulWidget {
  @override
  _ExpenseListScreenState createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  List<Expense> _expenses = [];
  List<dynamic> _predictions = [];
  List<dynamic> _predictionDates = [];

  @override
  void initState() {
    super.initState();
    _fetchExpenses();
  }

  Future<void> _getPredictions() async {
    try {
      final url = 'http://localhost:5000/predict_expenses';
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(_expenses.map((e) => e.toJson()).toList()),
      );

      if (response.statusCode == 200) {
        // Convert the response body to bytes and navigate to the PredictionGraphScreen
        final imageBytes = response.bodyBytes;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PredictionGraphScreen(imageBytes: imageBytes),
          ),
        );
      } else {
        print('Failed to get predictions: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _fetchExpenses() async {
    final response = await http.get(Uri.parse('http://localhost:3000/expenses'));
    if (response.statusCode == 200) {
      final List<dynamic> expenseJson = jsonDecode(response.body);
      setState(() {
        _expenses = expenseJson.map((json) => Expense.fromJson(json)).toList();
      });
    } else {
      throw Exception('Failed to load expenses');
    }
  }

  Future<void> _addExpense(Expense expense) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/expenses'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(expense.toJson()),
      );

      if (response.statusCode == 201) {
        _fetchExpenses(); // Reload expenses after adding a new one
      } else {
        print('Failed to add expense: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _deleteExpense(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('http://localhost:3000/expenses/$id'),
      );

      if (response.statusCode == 200) {
        _fetchExpenses(); // Reload expenses after deletion
      } else {
        print('Failed to delete expense: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Expenses'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.analytics),
            onPressed: _getPredictions,
          ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              _showAddExpenseDialog(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _expenses.isEmpty
                ? Center(child: Text('No expenses added yet!'))
                : ListView.builder(
                    itemCount: _expenses.length,
                    itemBuilder: (context, index) {
                      final expense = _expenses[index];
                      return ListTile(
                        title: Text(expense.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(expense.category),
                            Text(DateFormat.yMMMd().format(expense.date)),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('\$${expense.amount.toStringAsFixed(2)}'),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                _deleteExpense(expense.id); // Call delete method
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          // Display predictions here
          if (_predictions.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(
                    'Predicted Future Expenses:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: _predictions.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(
                          'Date: ${_predictionDates[index]}',
                        ),
                        trailing: Text(
                          '\$${_predictions[index].toStringAsFixed(2)}',
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _showAddExpenseDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddExpenseDialog(
          onAddExpense: _addExpense,
        );
      },
    );
  }
}
