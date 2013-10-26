from flask import Flask, render_template, request, Response
import time
import json

app = Flask(__name__)


# simulation of a real database, only fo demo purpose
cities = [
    {'name': 'Milan', 'country': 'Italy', 'population': 1295000, 'timezone': 'CET', 'capital': False, 'demonym': 'Milanees'},
    {'name': 'Rome', 'country': 'Italy', 'population': 2645000, 'timezone': 'CET', 'capital': True, 'demonym': 'Roman'},
    {'name': 'Venice', 'country': 'Italy', 'population': 270000, 'timezone': 'CET', 'capital': False, 'demonym': 'Venetians'},
    {'name': 'London', 'country': 'UK', 'population': 8300000, 'timezone': 'GMT', 'capital': True, 'demonym': 'Londoner'},
    {'name': 'Cambridge', 'country': 'UK', 'population': 122000, 'timezone': 'GMT', 'capital': False, 'demonym': '-'},
    {'name': 'Paris', 'country': 'France', 'population': 10400000, 'timezone': 'CET', 'capital': True, 'demonym': 'Parisiens'},
    {'name': 'Madrid', 'country': 'Spain', 'population': 3265000, 'timezone': 'CET', 'capital': True, 'demonym': 'Madrilenian'},
]


@app.route('/')
def test():
    return render_template('test.html')


@app.route('/ajax/cities')
def ajax_cities():
    time.sleep(1)  # delay simulation
    order_by = request.args.get('orderBy', 0, type=str)
    name = request.args.get('name', 0, type=str)
    country = request.args.get('country', 0, type=str)
    desceding = "-" in order_by
    order_by = order_by.split("-")[-1]
    cities_filtered = [c for c in cities if name.lower() in c['name'].lower() and country.lower() in c['country'].lower()]
    cities_filtered = sorted(cities_filtered, key=lambda c: c[order_by], reverse=desceding)
    json_data = json.dumps(cities_filtered)
    response = Response(json_data, status=200, mimetype='application/json')

    return response


if __name__ == '__main__':
    app.run()
