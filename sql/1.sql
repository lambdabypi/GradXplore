CREATE TABLE expenses (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255),
  amount DECIMAL(10, 2),
  date DATETIME,
  category VARCHAR(255)
);

select * from expenses;

ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'DBMS@2023*';
FLUSH PRIVILEGES;