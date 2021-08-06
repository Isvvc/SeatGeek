# SeatGeek

A simple SeatGeek app for iOS

## Build

Building Character Tracker requires Xcode 11+ on macOS 10.14.4 or later for iOS Swift Package Manager support.

### Dependencies

Dependencies are obtained automatically by Xcode through Swift Package Manager.

* [SwiftyJSON](https://github.com/SwiftyJSON/SwiftyJSON)

### API Key

You'll need to add a [SeatGeek API key](https://seatgeek.com/account/develop) to your scheme to be able to test (requires a SeatGeek account).

Edit your scheme in Xcode. Ensure the "Shared" checkbox is _unchecked_ to keep the scheme private.

Under Arguments in Run, add the following environment variable:

+ `client_id`: Your client ID for the SeatGeek API.

## License

This project is open-source and licensed under the [MIT License](LICENSE).
