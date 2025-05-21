# Gateway Experience Player (MVP)

A Flutter-based Android application designed for personal use to play The Gateway Experience audio files. This MVP allows users to browse different "Waves," download individual FLAC tracks from a personal server, and listen to them with a custom-designed player.

## Features

*   **Wave Navigation:** Easily browse through different Waves of The Gateway Experience.
*   **Track Listing:** View all tracks within each Wave.
*   **Server-Side Downloads:**
    *   Tracks are listed with a download button.
    *   Download progress is shown with a circular indicator and percentage.
    *   Downloaded/Total size displayed during download.
    *   Downloaded tracks are marked and available for offline playback.
*   **FLAC Audio Playback:** Utilizes `just_audio` for high-quality FLAC file playback.
*   **Custom Audio Player UI:**
    *   Play/Pause, Next, and Previous controls.
    *   Seekable progress bar with current time and total duration.
    *   Displays current track title and its Wave.
    *   "Sine wave" style animation that moves based on audio playback state (IN PROGRESS).
*   **Modern & Elegant Design:** Simple UI with subtle gradients and a custom color palette..
*   **Offline Playback:** Once tracks are downloaded, they can be played without an internet connection.

## Built With

*   [Flutter](https://flutter.dev/) - UI toolkit for building natively compiled applications.
*   [Provider](https://pub.dev/packages/provider) - State management.
*   [just_audio](https://pub.dev/packages/just_audio) - Audio playback for FLAC files.
*   [just_audio_background](https://pub.dev/packages/just_audio_background) - Background audio playback and notification controls (*integration currently paused due to a native Android issue being diagnosed*).
*   [Dio](https://pub.dev/packages/dio) - HTTP client for file downloads.
*   [path_provider](https://pub.dev/packages/path_provider) - Finding local file system paths.
*   [shared_preferences](https://pub.dev/packages/shared_preferences) - Persistent storage for download status.
*   [equatable](https://pub.dev/packages/equatable) - Simplifying model value comparisons.

## Getting Started

**Prerequisites:**

*   Flutter SDK installed.
*   An Android device or emulator.
*   A server hosting the FLAC audio files.

**Setup:**

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/your-username/gateway-experience-app.git
    cd gateway-experience-app
    ```

2.  **Configure Server URL:**
    The application expects audio files to be hosted on a server. You need to configure the base URL for your audio files.
    *   **Option 1 (Recommended for Security): Environment Variables**
        Create a file named `.env` in the root of the project (this file **should be gitignored**):
        ```env
        SERVER_BASE_URL=https://your-actual-server.com/audio-path
        ```
        You will need to set up a mechanism to load this at runtime (e.g., using `flutter_dotenv` package). *This setup is not yet implemented in the current MVP code but is highly recommended.*

    *   **Option 2 (Current MVP Setup - For Local Development Only):**
        Crete the file `lib/utils/constants.dart` and modify the `AppConstants.serverBaseUrl` :
        ```dart
        class AppConstants {
          // IMPORTANT: Replace with your actual server URL FOR DEVELOPMENT
          static const String serverBaseUrl = "https://your-server.com/audio-files";
        }
        ```

3.  **Define Track List:**
    The list of Waves and Tracks is currently hardcoded in `lib/providers/track_library_provider.dart` in the `_initialWavesData` variable. Update this list with your track details and their relative paths on the server.
    ```dart
    List<WaveModel> _initialWavesData = [
      WaveModel(name: "Wave I: Discovery", tracks: [
        TrackModel(id: "w1_t1", title: "Orientation", waveName: "Wave I", trackUrl: "wave1/discovery_01_orientation.flac"),
        // ... more tracks
      ]),
      // ... more waves
    ];
    ```

4.  **Install dependencies:**
    ```bash
    flutter pub get
    ```

5.  **Run the application:**
    ```bash
    flutter run
    ```

## UI Style

The app aims for a simple, modern, and elegant UI, using a custom color palette:
*   Dark Blue: `#0A192F`
*   Slate Gray: `#233554`
*   Light Gray: `#A8B2D1`
*   Dark Gray: `#8892B0`
*   Mint Green (Accent): `#64FFDA`
*   White (Text): `#CCD6F6`

Subtle gradients are used for backgrounds. Default Material Design styles are overridden where necessary to achieve a unique look and feel.

## Future Improvements (Post-MVP)

*   Fully resolve and re-enable `just_audio_background` for robust background playback and notification controls.
*   Fetch track list/manifest from the server instead of hardcoding.
*   Implement a secure way to manage `serverBaseUrl` (e.g., using `flutter_dotenv`).
*   User settings (e.g., clear downloaded files, theme options).
*   Search and filter tracks.
*   True audio-reactive visualizer (using FFT data).
*   Sleep timer.

## Contributing

This is a personal MVP project. However, suggestions and discussions are welcome via Issues.

## License

This project is for personal use. Please respect the copyright of The Gateway Experience audio material.
(You might want to add a specific open-source license like MIT if you intend for others to use the code itself, but be very clear about the audio content itself not being part of that license).