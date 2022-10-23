#!/usr/bin/env python
# encoding: utf-8

import json
from flask import Flask, request, jsonify

app = Flask(__name__)


@app.route('/', methods=['POST'])
def index():
    record = json.loads(request.data)
    return jsonify({'name': 'alice',
                    'email': 'alice@outlook.com'})

if __name__ == '__main__':
    app.run()
