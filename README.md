# Driver Cognitive Load and Drowsiness Detection System

**Academic Engineering Project**  
*Flutter + MediaPipe + SQLite*

## Overview
This application detects driver drowsiness and estimates cognitive load using real-time facial analysis from the smartphone's front camera. It is designed as an offline-first, free, and privacy-focused solution for driver safety.

## Features
1.  **Real-time Drowsiness Detection**: Uses Eye Aspect Ratio (EAR) to detect eye closure.
2.  **Cognitive Load Estimation**: Analyzes blink frequency and face attention to estimate load (Low/Medium/High).
3.  **Local Alerts**: Audio and visual warnings.
4.  **Offline Logs**: Stores session data in local SQLite database.
5.  **Simulated Emergency**: Demonstrates emergency response protocol logic.

## Setup Instructions

### Prerequisites
- Flutter SDK (>=3.0.0)
- Android Studio / VS Code
- Android Device (Emulator may not support Camera correctly)

### Installation
1.  **Clone/Copy** this project folder.
2.  **Install Dependencies**:
    ```bash
    flutter pub get
    ```
3.  **Run Application**:
    ```bash
    flutter run
    ```

## Project Structure
- `lib/logic`: Core algorithms (Face Mesh, EAR, Cognitive Load).
- `lib/providers`: State management connecting Camera to Logic.
- `lib/ui`: User Interface screens and widgets.
- `lib/database`: SQLite local storage.

## Algorithms
- **EAR**: `(|p2-p6| + |p3-p5|) / (2 * |p1-p4|)`
- **Cognitive Load**: Inverse correlation with Blink Rate (Tunnel Vision = High Load).

## Troubleshooting
- **Camera Permission**: Ensure you grant camera permissions on first launch.
- **Min SDK**: Requires Android Min SDK 21.

