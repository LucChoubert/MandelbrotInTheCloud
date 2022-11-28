#!/usr/bin/env python
# encoding: utf-8

import json
import io
from PIL import Image
from flask import Flask, request, jsonify, send_file
from MandelbrotPoint import MandelbrotPoint, MandelbrotSet

app = Flask(__name__)


# Return iconfile
@app.get('/favicon.ico')
def get_ico():
    filename = 'favicon.ico'
    return send_file(filename, mimetype='image/vnd.microsoft.icon')

# Test endpoint to quickly check that backend is up and running
@app.get('/test')
def test():
    return jsonify({'status': 'up'})

# Endpoint to draw the Mandelbrot Set fractale
@app.post('/draw')
def draw_image():
    # Get & decode the input json
    record = json.loads(request.data)

    # Build the Mandelbrot Set
    mSet = MandelbrotSet(float(record['xmin']),
                         float(record['xmax']),
                         float(record['ymin']),
                         float(record['ymax']))
    mSet.compute()

    # Build reply as a jpeg image
    myImage = mSet.exportToImage()
    buf = io.BytesIO()
    myImage.save(buf, format='JPEG')

    return buf.getvalue(), {"Content-Type": "image/jpeg"}

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)

