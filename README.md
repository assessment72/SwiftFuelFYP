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
To deploy and run the code, ensure you have the following installed and set up on your system:

1. **Flutter SDK**: You need Flutter installed on your system. Follow the official guide for installation: [Flutter Installation Guide](https://flutter.dev/docs/get-started/install).
2. **Android Studio**: Install Android Studio with the Flutter and Dart plugins. This will be your Integrated Development Environment (IDE) to open and run the project. Make sure you also install the Android SDK components during Android Studio setup.

## Setup and Deployment Instructions

1. **Open the Project in Android Studio**
   - Download or clone the project repository to your local system:
   - Open Android Studio and select **"Open an Existing Project"**. Browse to the `fuel_delivery_app` folder and open it.

2. **Set Up an Emulator or Physical Device**
   - In Android Studio, go to **"Device Manager"** from the top-right corner.
   - If you don't already have an emulator set up:
     - Click on **"Create Device"**.
     - Select a suitable virtual device, such as **Pixel 9** with API **35** and **Android 15**.
     - Choose a system image (e.g., Android API level 30 or higher) and complete the setup.
   - Alternatively, connect a physical Android device via USB. Make sure USB debugging is enabled on the device and the necessary drivers are installed.

3. **Install Dependencies**
   - Open the terminal in Android Studio (or your system terminal, making sure you are in the project directory).
   - Run the following command to install all the required Flutter packages and dependencies:
     ```sh
     flutter pub get
     ```

## Running the App

1. **Run the App**
   - In Android Studio:
     - Select the connected emulator or physical device from the dropdown menu at the top of the IDE.
     - Click the **"Run"** button (the green play icon) to compile and deploy the app.
   - Alternatively, from the terminal, you can run:
     ```sh
     flutter run
     ```

2. **Debugging and Troubleshooting**
   - If the app doesn't run as expected or you encounter issues:
     - Use the verbose mode to get detailed logs:
       ```sh
       flutter run -v
       ```
     - Ensure the emulator is running or the physical device is properly connected.
     - Check the terminal or logcat in Android Studio for detailed error messages.

3. **Firebase and Google Maps**
   - The project is pre-configured with Firebase and Google Maps API. Ensure you are connected to the internet so these services can work seamlessly.

By following these steps, you should be able to deploy and run the app easily. If any issues arise, refer to the detailed logs or documentation provided with Flutter and Android Studio.


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


