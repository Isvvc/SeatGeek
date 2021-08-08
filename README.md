# SeatGeek

A simple SeatGeek app for iOS

<img src="Screenshots/iPhone 8 Plus - Events.png" height=400 /> <img src="Screenshots/iPhone 8 Plus - Event.png" height=400 /> <img src="Screenshots/iPhone 8 Plus - Search.png" height=400 /> <img src="Screenshots/iPhone 8 Plus - Favorites.png" height=400 />

## Features

+ Browse events from all across the world.
+ Search for specific events or locations.
+ Favorite events to see later.

### Requirements

Requires iOS 12.1 or later.

## Build

Building SeatGeek iOS requires Xcode 11+ on macOS 10.14.4 or later for iOS Swift Package Manager support.

### Dependencies

Dependencies are obtained automatically by Xcode through Swift Package Manager.

+ [SwiftyJSON](https://github.com/SwiftyJSON/SwiftyJSON)
+ [SDWebImage](https://github.com/SDWebImage/SDWebImage)

### API Key

You'll need to add a [SeatGeek API key](https://seatgeek.com/account/develop) to the project to be able to test (requires a SeatGeek account).

1. Create a Config.xcconfig file in the SeatGeek folder (make sure it's named exactly this so it isn't commited to git).
1. Enter `CLIENT_ID = ` followed by your SeatGeek client_id.
1. In the project settings under Info, Configuration, set the project's configuration file to the one you just made.

## License

This project is open-source and licensed under the [MIT License](LICENSE).
