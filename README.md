<div align=center>
  <img src='resources/appIcon.jpeg' alt='JellyMusic icon' width=128 height=128 />
  <div align=center>
    <h1>JellyMusic</h1>
    <p>A native iOS Jellyfin client for music playback</p>
  </div>
</div>

## About

JellyMusic is a native iOS client for music playback, written in Swift and SwiftUI with the aim to provide a clean and native-looking interface which fits right into the iOS design. The UI layout is directly based on the Apple Music app.

## Features

The app currently offers pretty basic functions, with the most notable being:

- Online and offline playback
- Gapless playback[^1]
- Playback reporting
- UI customization
- Customizable bitrate to save data


[^1]: Requires properly encoded files for lossy formats - learn more [here](https://en.wikipedia.org/wiki/Gapless_playback#Format_support)

## Development

1. Clone the repository
2. Open project in Xcode
3. You should be done; the project uses SPM for dependencies, Xcode should automatically install them

## Releases

There are no releases right now as the app is still pretty basic and still missing a lot of stuff to make it usable for others. Still, if you want to check it out, you can sideload it from Xcode. 

Once the app will be in a somewhat presentable shape, I'll provide IPAs here and consider setting up TestFlight.
