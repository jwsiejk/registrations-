
from flask import Flask, request, jsonify
import pandas as pd
from datetime import datetime

app = Flask(__name__)
df = pd.read_csv('opportunity_data.csv', parse_dates=['Created Date'])

@app.route('/filter', methods=['POST'])
def filter_data():
    data = request.get_json()
    start = datetime.strptime(data['start'], '%m/%d/%Y')
    end = datetime.strptime(data['end'], '%m/%d/%Y')

    filtered = df[(df['Created Date'] >= start) & (df['Created Date'] < end)]
    total = len(filtered)
    registered = filtered['Registered'].sum()
    not_registered = total - registered
    percent = round((registered / total) * 100, 2) if total > 0 else 0.0

    return jsonify({
        'total': total,
        'registered': int(registered),
        'not_registered': int(not_registered),
        'percent_registered': f"{percent}%"
    })

if __name__ == '__main__':
    app.run(debug=True)
