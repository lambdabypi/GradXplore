import 'package:flutter/material.dart';
import 'expense.dart';

class AddExpenseDialog extends StatefulWidget {
  final Function(Expense) onAddExpense;

  AddExpenseDialog({required this.onAddExpense});

  @override
  _AddExpenseDialogState createState() => _AddExpenseDialogState();
}

class _AddExpenseDialogState extends State<AddExpenseDialog> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  String _selectedCategory = 'Food'; // Default category
  DateTime _selectedDate = DateTime.now();

  // List of categories for the dropdown
  final List<String> _categories = ['Food', 'Transport', 'Entertainment', 'Utilities', 'Others'];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Expense'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: InputDecoration(labelText: 'Name'),
          ),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(labelText: 'Amount'),
          ),
          DropdownButton<String>(
            value: _selectedCategory,
            items: _categories.map((String category) {
              return DropdownMenuItem<String>(
                value: category,
                child: Text(category),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedCategory = newValue!;
              });
            },
            isExpanded: true,
          ),
          ListTile(
            title: Text('Date: ${_selectedDate.toLocal().toString().split(' ')[0]}'),
            trailing: Icon(Icons.calendar_today),
            onTap: _pickDate,
          ),
        ],
      ),
      actions: [
        TextButton(
          child: Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        ElevatedButton(
          child: Text('Add'),
          onPressed: () {
            final name = _nameController.text;
            final amount = double.parse(_amountController.text);

            if (name.isNotEmpty && amount > 0) {
              final expense = Expense(
                id: 0,
                name: name,
                amount: amount,
                date: _selectedDate,
                category: _selectedCategory
              );
              widget.onAddExpense(expense);
              Navigator.of(context).pop();
            }
          },
        ),
      ],
    );
  }

  void _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }
}
