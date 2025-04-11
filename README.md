
# SwiftFuel – Fuel Delivery Mobile App 🚗⛽

SwiftFuel is a mobile application designed to provide on-demand fuel delivery directly to a user’s location. Built as part of a university final year project, this Android app offers a seamless user experience with features like real-time GPS tracking, secure payments, and Firebase-based backend integration.

SwiftFuel empowers users to place fuel orders effortlessly and track deliveries live from their smartphones—eliminating the need to visit petrol stations.

---

## 🚀 Features

- 🔐 **User Authentication**  
  Secure registration and login via Firebase Authentication.

- 🗺️ **Real-Time GPS Tracking**  
  Google Maps API integration for location selection and live delivery tracking.

- ⛽ **Fuel Ordering System**  
  Users can order petrol, diesel, or premium fuels by selecting delivery location and vehicle info.

- 💳 **Stripe Payment Integration**  
  Secure in-app payment using Stripe (test mode enabled).

- 🧭 **Order Tracking**  
  Live status updates and route drawing between delivery driver and customer using Google Maps.

- 👨‍✈️ **Driver/Delivery Partner Dashboard**  
  Role-based access control with a dedicated interface for delivery drivers.

- 📜 **Past Orders History**  
  View previous completed orders stored in Firestore.

- ⚙️ **User Profile Management**  
  Change password functionality and display of user info.

---

## 🧰 Technologies Used

| Technology      | Purpose                            |
|----------------|-------------------------------------|
| Flutter         | Cross-platform app development     |
| Dart            | Primary language for Flutter       |
| Firebase        | Authentication and Firestore DB    |
| Google Maps API | Live GPS & delivery tracking       |
| Stripe API      | Secure payment processing          |

---

## 🛠 Prerequisites

Make sure you have the following installed:

- Flutter SDK ([Install Guide](https://flutter.dev/docs/get-started/install))
- Android Studio with Flutter and Dart plugins
- A physical Android device or emulator
- Internet access (required for Maps, Firebase, and payments)

---

## 📦 Project Structure

```
.
├── android/
├── ios/
├── lib/
│   ├── main.dart
│   ├── screens/
│   ├── services/
├── pubspec.yaml
```

---

## 🧪 How to Run SwiftFuel Locally

1. **Clone the repository** or download the project ZIP.
2. **Open in Android Studio**: Go to **File > Open** and select the project folder.
3. **Set up a virtual or real device**:
   - Virtual: Use AVD Manager to create a device (API 30+ recommended).
   - Real: Enable USB debugging on your Android phone and connect it.
4. **Install dependencies**:
   ```bash
   flutter pub get
   ```
5. **Run the app**:
   - Via Android Studio (Run ▶️ button), or
   - Via terminal:
     ```bash
     flutter run
     ```

---

## 📲 Usage Instructions

- Register a new account with email and mobile number.
- Log in securely to access the home screen.
- Tap **Order Fuel**, select your location, fuel type, and vehicle plate.
- Confirm your order and complete payment using Stripe’s test card.
- Track your delivery in real time via the **Order Tracking** screen.
- View **Past Orders** and manage your profile from the menu.

---

## 🧩 Troubleshooting

- 🔑 **Google Maps not loading**: Check internet connection. API key is pre-configured.
- 📦 **Missing dependencies**: Run `flutter pub get` in the terminal.

---

## 🔮 Future Scope

While SwiftFuel was built for academic purposes, future updates could include:

- Support for iOS platform
- Dynamic fuel pricing based on market data
- ETA calculation for deliveries
- Live customer support chat
- Backend migration from Firebase to custom scalable infrastructure

---

## 👨‍💻 About the Developer

**Fahad Riaz**  
Final year BSc Computer Science student  
Royal Holloway, University of London  

🔗 [LinkedIn](https://www.linkedin.com/in/fahad-riaz-9a76a62b4) | 📧 fahad.riaz22@hotmail.com 

This project was developed as part of my final year dissertation under the supervision of **Vasudha Darbari**. The goal was to create an impactful mobile application that solves a real-world problem through technology.

---
