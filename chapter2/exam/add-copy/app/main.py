from flask import Flask, send_from_directory

app = Flask(__name__, static_folder='/app/static')

@app.route('/')
def hello_gemini():
    return "Hello, Gemini! This file was copied using the COPY command."

@app.route('/static/<path:path>')
def send_static(path):
    return send_from_directory('/app/static', path)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)
