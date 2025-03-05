# BuzzMatch v5

BuzzMatch is a Flutter application that connects content creators with brands for advertising campaigns. The app allows brands to create campaigns and match with content creators who can produce quality promotional content.

## Features

### User Types
- **Content Creators**: Upload and showcase their work, apply to campaigns, and collaborate with brands.
- **Brands**: Create campaigns, find content creators, and manage advertising projects.

### Core Features
- **Authentication**: Email/password and social login options (Google/Apple)
- **Campaign Management**: Create, manage, and track advertising campaigns
- **Matching System**: Connect brands with suitable content creators
- **Collaboration Status Tracking**: Follow project progress from initial match to completion
- **Payment & Escrow System**: Secure payment handling between brands and creators
- **Wallet System**: Manage funds and track transaction history
- **Real-time Chat**: Communication between brands and creators
- **Localization**: Support for English and Arabic languages

## Technical Specifications

- **Framework**: Flutter for cross-platform development
- **State Management**: GetX
- **Backend**: Firebase (Authentication, Firestore, Storage, Messaging)
- **Payment Integration**: Stripe/PayPal
- **Design**: Bee-inspired UI with hexagonal buttons and honeycomb aesthetic

## Getting Started

### Prerequisites
- Flutter SDK (latest stable version)
- Dart SDK
- Firebase account and project setup
- Stripe/PayPal developer accounts

### Installation
1. Clone the repository
   ```
   git clone https://github.com/yourusername/buzzmatch_v5.git
   cd buzzmatch_v5
   ```

2. Install dependencies
   ```
   flutter pub get
   ```

3. Connect to Firebase
   - Create a Firebase project in the Firebase Console
   - Set up Firebase Authentication, Firestore, and Storage
   - Download and add the `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) files to the project

4. Set up Stripe/PayPal
   - Create Stripe/PayPal developer accounts
   - Add your API keys to the project

5. Run the app
   ```
   flutter run
   ```

## Project Structure

```
buzzmatch_v5/
├── lib/
│   ├── main.dart               # Entry point
│   ├── app/
│   │   ├── bindings/           # GetX bindings
│   │   ├── data/
│   │   │   ├── models/         # Data models
│   │   │   ├── providers/      # API providers
│   │   │   ├── repositories/   # Repository implementations
│   │   │   └── services/       # Services (Firebase, Payment, etc.)
│   │   ├── modules/            # Feature modules
│   │   │   ├── authentication/ # Authentication screens & controllers
│   │   │   ├── brand/          # Brand-specific screens & controllers
│   │   │   ├── campaign/       # Campaign management
│   │   │   ├── chat/           # Chat functionality
│   │   │   ├── creator/        # Creator-specific screens & controllers
│   │   │   ├── dashboard/      # Dashboard screens
│   │   │   ├── payment/        # Payment & wallet functionality
│   │   │   ├── profile/        # User profiles
│   │   │   ├── splash/         # Splash screen
│   │   │   └── welcome/        # Welcome screen
│   │   ├── routes/             # App routes
│   │   │   └── app_pages.dart  # Route definitions
│   │   ├── theme/              # App theme
│   │   │   ├── app_colors.dart # Color definitions
│   │   │   ├── app_text.dart   # Text styles
│   │   │   └── app_theme.dart  # Theme data
│   │   ├── translations/       # Localization files
│   │   │   ├── ar_SA/          # Arabic translations
│   │   │   ├── en_US/          # English translations
│   │   │   └── app_translations.dart
│   │   └── utils/              # Utility functions
│   │       ├── constants.dart
│   │       ├── helpers.dart
│   │       └── widgets/        # Reusable widgets
├── assets/
│   ├── fonts/                  # Custom fonts
│   ├── images/                 # Image assets
│   ├── animations/             # Lottie animations
│   └── icons/                  # Custom icons
```

## Development Workflow

1. **Authentication Flow**
   - Users are presented with the welcome screen to select their role
   - They can sign up or log in using email/password or social logins
   - After authentication, they are directed to their respective dashboards

2. **Brand Workflow**
   - Brands create campaigns with detailed information
   - They can browse and invite content creators
   - Once a creator applies or accepts an invitation, brands can review and match
   - Brands monitor the collaboration progress through status updates
   - Upon content approval, brands release payment from escrow

3. **Creator Workflow**
   - Creators set up their profile and portfolio
   - They browse available campaigns and apply to relevant ones
   - When matched with a brand, they can communicate via chat
   - Creators update their progress status as they work
   - Upon content approval, creators receive payment

## Firebase Setup Guide

### Authentication
Enable the following authentication methods in Firebase console:
- Email/Password
- Google Sign-In
- Apple Sign-In (for iOS)

### Firestore Database
Create the following collections:
- `users`: Store user profiles
- `campaigns`: Store campaign information
- `chats`: Store chat conversations
- `messages`: Store individual messages
- `transactions`: Store payment transactions
- `wallets`: Store user wallet information

### Firebase Storage
Set up storage for:
- User profile images
- Campaign reference materials
- Chat attachments
- Portfolio content

## Contributing
Contributions are welcome! Please feel free to submit a Pull Request.

## License
This project is licensed under the MIT License - see the LICENSE file for details.