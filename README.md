# Adventist Hymnarium (Flutter)

This is a Flutter-based mobile application providing access to the Adventist Hymnarium, including hymns and responsive readings.

## Features

*   Browse and search hymns and responsive readings.
*   View hymn lyrics and responsive reading texts.
*   Support for multiple hymnal versions (e.g., 1985 New Version, Old Version).
*   Favorites management for hymns and readings.
*   Recently viewed history.
*   Full-Text Search (FTS) capabilities.
*   Audio playback for hymns (requires media files).
*   Thematic index browsing.
*   Adjustable font size and other display settings.
*   Online database updates.

*(Add or remove features as applicable)*

## Getting Started

### Prerequisites

*   [Flutter SDK](https://flutter.dev/docs/get-started/install) installed (check `.flutter-version` or `pubspec.yaml` for specific version if needed).
*   An editor like [VS Code](https://code.visualstudio.com/) or [Android Studio](https://developer.android.com/studio).
*   A target device (Emulator/Simulator or physical device).

### Installation & Running

1.  **Clone the repository:**
    ```bash
    git clone git@github.com:RTSDA/Adventist-Hymnarium-Flutter.git
    cd Adventist-Hymnarium-Flutter
    ```

2.  **Install dependencies:**
    ```bash
    flutter pub get
    ```

3.  **Generate code (if needed):**
    The project uses `build_runner` for code generation (e.g., for Drift database).
    ```bash
    flutter pub run build_runner build --delete-conflicting-outputs
    ```

4.  **Run the app:**
    ```bash
    flutter run
    ```

### Database

The application uses a pre-populated SQLite database (`assets/hymnarium.db`).

*   **Initial Setup:** The app copies this database from the assets folder to the application's documents directory on first launch if it doesn't exist.
*   **Updates:** The app can download updated versions of the database from a remote server (currently configured to `https://adventisthymnarium.rockvilletollandsda.church/database/hymnarium.db`).
*   **Schema:** The database schema is defined using Drift in `lib/database/database.dart` and potentially `lib/database/schema.drift`.

## Project Structure (Overview)

*   `lib/`: Main application code.
    *   `database/`: Database setup (Drift), schema definition.
    *   `locator.dart`: Service locator setup (GetIt).
    *   `main.dart`: App entry point, Provider setup.
    *   `models/`: (If any specific data models besides generated ones)
    *   `screens/`: UI screens for different parts of the app.
    *   `services/`: Business logic services (Settings, Hymnal, Favorites, Audio, etc.).
    *   `widgets/`: Reusable UI components.

*(Adjust structure overview as needed)*

## Contributing

Contributions are welcome! Please follow these steps:

1.  Fork the repository.
2.  Create a new branch (`git checkout -b feature/your-feature-name`).
3.  Make your changes.
4.  Ensure code passes any linters/formatters (`flutter analyze`, `dart format .`).
5.  Commit your changes (`git commit -am 'Add some feature'`).
6.  Push to the branch (`git push origin feature/your-feature-name`).
7.  Create a new Pull Request.

*(Add more specific contribution guidelines if needed)*

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
