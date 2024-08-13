const express = require('express');
const mysql = require('mysql');
const bodyParser = require('body-parser');

const app = express();
app.use(bodyParser.json());

// MySQL connection
const connection = mysql.createConnection({
  host: 'localhost',
  user: 'root',
  password: 'DBMS@2023*',
  database: 'manageexpenses'
});

connection.connect(err => {
    if (err) throw err;
    console.log('MySQL Connected...');
  });
  
  // API to get expenses
  app.get('/expenses', (req, res) => {
    const sql = 'SELECT * FROM expenses';
    connection.query(sql, (err, results) => {
      if (err) throw err;
      res.json(results);
    });
  });
  
  // API to add a new expense
  app.post('/expenses', (req, res) => {
    const newExpense = {
      name: req.body.name,
      amount: req.body.amount,
      date: new Date(req.body.date),  // Ensure date is a valid Date object
      category: req.body.category
    };
    const sql = 'INSERT INTO expenses SET ?';
    connection.query(sql, newExpense, (err, result) => {
      if (err) throw err;
      res.status(201).json({ id: result.insertId, ...newExpense });
    });
  });
  
  // API to delete an expense
  app.delete('/expenses/:id', (req, res) => {
    const expenseId = req.params.id;
    const sql = 'DELETE FROM expenses WHERE id = ?';
    connection.query(sql, [expenseId], (err, result) => {
      if (err) throw err;
      res.status(200).json({ message: 'Expense deleted successfully' });
    });
  });

  app.listen(3000, () => {
    console.log('Server running on port 3000');
  });
