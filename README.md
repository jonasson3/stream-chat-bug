# stream_chat_bug

You need to sign up to Firebase.

Set up a Firebase auth emulator locally. Put a `google-services.json` under `app/src`. Get a `firebase_options.dart` under `lib` while setting up Firebase.

```
const String YOUR_API_KEY = ; this is your stream chat api key
```
# Backend
To install go into `backend` directory and run
```
pip install -r requirements.txt
```

Run the backend using
```
export FLASK_APP=hello
flask run
```

the update_user in the "update" post endpoint is necessary to trigger the bug


# Flutter
Actions to reproduce --> Register --> Click "Update" --> Click Sign Out. This should trigger bug.


Some key points to trigger bug.

```
If includeMatchesIcon==false, no issues
If includeMatchesIcon==true get issues when pushing `Update` followed by `Sign Out`
```

```
Watching the idTokenProvider is necessary to trigger the bugs
We need this in our original repo to get a token to fetch the chat token
final a = ref.watch(idTokenProvider);
```