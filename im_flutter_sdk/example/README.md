# im_flutter_sdk example

A minimal, self-contained example for the [`im_flutter_sdk`](https://pub.dev/packages/im_flutter_sdk) package. It covers the four basic steps of an EaseMob IM integration:

1. Initialize the SDK with your App Key.
2. Log in with a user ID and token.
3. Send a text message to a peer.
4. Receive messages through an event handler.
5. Observe send results (success / error / progress) through a message event.

## Run it

```bash
cd example
flutter pub get
flutter run
```

Fill in your App Key, user ID and token (issued by your app server via the REST API), then tap **Init** and **Login**.

> The full API testing workbench used by the SDK maintainers lives at `workbench/` in the repository root and is not part of the published package.
