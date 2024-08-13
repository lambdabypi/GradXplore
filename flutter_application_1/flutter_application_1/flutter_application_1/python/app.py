from flask import Flask, request, jsonify, send_file
import pandas as pd
from sklearn.linear_model import LinearRegression
import numpy as np
from datetime import datetime
import matplotlib.pyplot as plt
import io

app = Flask(__name__)

@app.route('/predict_expenses', methods=['POST'])
def predict_expenses():
    try:
        data = request.json
        if data is None:
            return jsonify({"error": "No data provided"}), 400

        df = pd.DataFrame(data)
        
        # Check if the required columns are in the dataframe
        if 'date' not in df.columns or 'amount' not in df.columns:
            return jsonify({"error": "Data must contain 'date' and 'amount' fields"}), 400

        # Convert date to numerical format (e.g., timestamp)
        df['date'] = pd.to_datetime(df['date'])
        df['date_ordinal'] = df['date'].map(datetime.toordinal)

        # Linear Regression model on 'amount' with respect to 'date'
        model = LinearRegression()
        model.fit(df[['date_ordinal']], df['amount'])

        # Predicting future expenses for the next 10 days
        future_dates = pd.date_range(start=df['date'].max(), periods=10)
        future_dates_ordinal = np.array([date.toordinal() for date in future_dates]).reshape(-1, 1)
        predictions = model.predict(future_dates_ordinal)

        # Plot the results
        plt.figure(figsize=(10, 5))
        plt.plot(df['date'], df['amount'], label='Historical Expenses', marker='o')
        plt.plot(future_dates, predictions, label='Predicted Expenses', marker='x', linestyle='--')
        plt.xlabel('Date')
        plt.ylabel('Expense Amount')
        plt.title('Expense Prediction Over Time')
        plt.legend()
        plt.grid(True)

        # Save the plot to a bytes buffer and return it as a response
        buf = io.BytesIO()
        plt.savefig(buf, format='png')
        buf.seek(0)
        plt.close()

        return send_file(buf, mimetype='image/png')

    except Exception as e:
        # Handle any exceptions that occur and return an error response
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    app.run(debug=True)
