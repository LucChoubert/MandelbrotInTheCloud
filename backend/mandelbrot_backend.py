#!/usr/bin/env python
# encoding: utf-8

import json
import io
import random
from PIL import Image
from flask import Flask, request, jsonify, send_file, url_for
from MandelbrotPoint import MandelbrotPoint, MandelbrotSet

app = Flask(__name__)


#ReDo it in a better way
# Doc here: https://flask.palletsprojects.com/en/2.2.x/patterns/favicon/
@app.get('/favicon.ico')
def get_ico():
    filename = 'favicon.ico'
    return send_file(filename, mimetype='image/vnd.microsoft.icon')

@app.post('/image')
def get_image():
    #record = json.loads(request.data)
    filename = 'mandelbrot.jpeg'
    return send_file(filename, mimetype='image/jpeg')

@app.post('/test')
def test():
    #record = json.loads(request.data)
    return jsonify({'name': 'alice',
                    'email': 'alice@outlook.com'})

@app.post('/draw')
def draw_image():
    record = json.loads(request.data)
    mode = "RGB"
    buf = io.BytesIO()
#    myImage = Image.new(mode, (640, 480), color=0)
#    for i in range(myImage.size[0]):  # for every pixel:
#        for j in range(myImage.size[1]):
#            myImage.putpixel((i, j), (random.randint(0, 255), random.randint(0, 255), random.randint(0, 255)))
    mSet = MandelbrotSet(float(record['xmin']),
                         float(record['xmax']),
                         float(record['ymin']),
                         float(record['ymax']))
    mSet.compute()
    myImage = mSet.exportToImage()
    myImage.save(buf, format='JPEG')
    return buf.getvalue(), {"Content-Type": "image/jpeg"}

if __name__ == '__main__':
    app.run()

