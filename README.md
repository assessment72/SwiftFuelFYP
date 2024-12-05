# Fuel Delivery Mobile App

## Project Overview
The Fuel Delivery Mobile App is an on-demand fuel delivery solution that allows users to conveniently order fuel at their preferred location. Users can select the type of fuel, provide their delivery location, and receive real-time updates on the delivery status. The application is built using Flutter, Firebase, and Google Maps API to ensure a seamless user experience. This README provides step-by-step guidance on how to deploy and run the application.

## Table of Contents
1. [Project Structure](#project-structure)
2. [Features](#features)
3. [Technologies Used](#technologies-used)
4. [Prerequisites](#prerequisites)
5. [Setup and Deployment Instructions](#setup-and-deployment-instructions)
6. [Running the App](#running-the-app)
7. [Usage](#usage)
8. [Troubleshooting](#troubleshooting)

## Project Structure
```
.
|-- android              # Android platform-specific code
|-- ios                  # iOS platform-specific code
|-- lib                  # Main source code for the app
|   |-- services         # Backend service-related files (Firebase integration, etc.)
|   |-- screens          # UI screen code for the app
|   |-- main.dart        # Entry point for the Flutter application
|-- pubspec.yaml         # Project dependencies and assets
```

## Features SO FAR
- User authentication (Registration and Login) using Firebase.
- Order fuel for your vehicle with real-time GPS tracking.
- Select delivery location using Google Maps.

## Technologies Used
- **Flutter**: Cross-platform development.
- **Firebase**: Backend-as-a-Service (Authentication, Firestore, Cloud Functions).
- **Google Maps API**: Real-time location tracking for delivery.

## Prerequisites
To deploy the code, ensure you have the following:
1. **Flutter SDK** installed - [Flutter Installation Guide](https://flutter.dev/docs/get-started/install)
2. **Android Studio or VS Code** installed with the Flutter plugin.
3. **Firebase Project** set up:
   - Create a Firebase project in the [Firebase Console](https://console.firebase.google.com/).
   - Enable Firebase Authentication and Firestore Database.

## Setup and Deployment Instructions
1. **Clone the Repository**
   ```sh
   git clone <repository_url>
   cd PROJECT
   ```

2. **Install Dependencies**
   Run the following command to install the Flutter packages and dependencies:
   ```sh
   flutter pub get
   ```


## Running the App
1. **Run the App on an Emulator or Device**
   - Ensure that an emulator or a physical device is connected.
   - Run the following command:
     ```sh
     flutter run
     ```

2. **Debugging**
   If there are issues while running the app, use the following command for more verbose output:
   ```sh
   flutter run -v
   ```

## Usage
- **Registration/Login**: Users must create an account using their email or log in with an existing account.
- **Order Fuel**: Users can select the delivery location on Google Maps, choose fuel type, and confirm their order.

## Troubleshooting
- **API Key Issues**: If Google Maps does not load, ensure the API key is set correctly and the Maps API is enabled.
- **Firebase Authentication**: Ensure Firebase Authentication is enabled for email/password sign-in.
- **Dependencies**: Run `flutter pub get` to resolve missing dependencies.

## Future Scope
- Adding iOS support (currently, the project only targets Android).
- Term 2 development left as mentioned in the Interim Report


If you encounter any issues during deployment, please feel free to reach out to the developer. 


