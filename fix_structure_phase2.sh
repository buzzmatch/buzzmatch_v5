#!/bin/bash

# Move files to their correct locations
mkdir -p lib/app/data/models/
mkdir -p lib/app/modules/authentication/controllers/
mkdir -p lib/app/translations/en_US/
mkdir -p lib/app/translations/ar_SA/

# Move theme files
if [ -f "lib/app_colors.dart" ]; then
  cp "lib/app_colors.dart" "lib/app/theme/app_colors.dart"
  rm "lib/app_colors.dart"
fi

if [ -f "lib/app_text.dart" ]; then
  cp "lib/app_text.dart" "lib/app/theme/app_text.dart"
  rm "lib/app_text.dart"
fi

# Move theme directory
if [ -d "lib/theme" ]; then
  cp -r "lib/theme/." "lib/app/theme/"
  rm -rf "lib/theme"
fi

# Move controllers to correct locations
if [ -f "lib/app/controllers/auth_controller.dart" ]; then
  mkdir -p "lib/app/modules/authentication/controllers/"
  cp "lib/app/controllers/auth_controller.dart" "lib/app/modules/authentication/controllers/"
  rm "lib/app/controllers/auth_controller.dart"
fi

if [ -f "lib/app/controllers/splash_controller.dart" ]; then
  mkdir -p "lib/app/modules/splash/controllers/"
  cp "lib/app/controllers/splash_controller.dart" "lib/app/modules/splash/controllers/"
  rm "lib/app/controllers/splash_controller.dart"
fi

# Move models to correct location
if [ -d "lib/data/models" ]; then
  cp -r "lib/data/models/." "lib/app/data/models/"
  rm -rf "lib/data/models"
fi

# Move translation files
if [ -f "lib/en_US/en_US.dart" ]; then
  mkdir -p "lib/app/translations/en_US/"
  cp "lib/en_US/en_US.dart" "lib/app/translations/en_US/"
  rm -rf "lib/en_US"
fi

if [ -f "lib/ar_SA/ar_SA.dart" ]; then
  mkdir -p "lib/app/translations/ar_SA/"
  cp "lib/ar_SA/ar_SA.dart" "lib/app/translations/ar_SA/"
  rm -rf "lib/ar_SA"
fi

echo "File structure has been fixed."
