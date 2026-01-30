## Weather App

A modern Flutter weather application that provides real-time weather updates and hourly forecasts using the OpenWeather API. The app supports city search and live location-based weather with a clean and minimal UI.

---

## Features

### Live Location Weather
- Fetches current weather using device GPS  
- Handles location permissions gracefully  

### Search by City
- Search and view weather for any city worldwide  

### Hourly Weather Forecast
- Displays upcoming hourly temperature and conditions  
- Automatically converts UTC time to local time  

### Current Weather Details
- Temperature  
- Weather condition and description  
- City name  

### Additional Information
- Humidity  
- Wind speed  
- Pressure  

### UI and Design
- Glassmorphism-style cards  
- Dark theme  
- Smooth horizontal scrolling forecast  

---

## Setup Instructions

Clone the repository:
```bash
git clone https://github.com/Harshit-0413/weather-app-flutter.git
cd weather-app-flutter

Install dependencies:

flutter pub get

Create a .env file in the root directory:

WEATHER_API=your_api_key_here

Run the app:

flutter run

