from flask import session
from flask import Flask
from flask import jsonify
from flask import request
import stream_chat
import os

# TO INSTALL:
# pip install -r requirements.txt

# TO RUN:
# export FLASK_APP=hello
# flask run


app = Flask(__name__)
STREAM_CHAT_API_KEY = os.environ.get('STREAM_CHAT_API_KEY')
STREAM_CHAT_SECRET = os.environ.get('STREAM_CHAT_SECRET')

client = stream_chat.StreamChat(api_key=STREAM_CHAT_API_KEY, api_secret=STREAM_CHAT_SECRET)

@app.get("/api/update/<id>")
def update(id):
    upsert_dict = dict(
        id=id,
        image="https://picsum.photos/200/200",
        name="namereerr"
    )
    client.upsert_user(upsert_dict)
    return jsonify({})

@app.get("/api/chat-token/<id>")
def chattoken(id):
    return jsonify({'token': client.create_token(id)})

