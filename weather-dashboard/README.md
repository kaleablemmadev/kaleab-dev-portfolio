# Weather Dashboard

[![React](https://img.shields.io/badge/React-18-blue)](https://reactjs.org/)
[![TypeScript](https://img.shields.io/badge/TypeScript-5.2-blue)](https://www.typescriptlang.org/)
[![Vite](https://img.shields.io/badge/Vite-5.0-purple)](https://vitejs.dev/)
[![Tailwind](https://img.shields.io/badge/Tailwind-3.4-cyan)](https://tailwindcss.com/)
[![Live Demo](https://img.shields.io/badge/Live-Demo-green)](https://weather-dashboard-v2-omega.vercel.app/)

## Description

A modern weather dashboard built with React and TypeScript that provides real-time weather information for any city worldwide. This project demonstrates API integration, error handling, TypeScript type safety, and responsive design.

**Why I built this:** I wanted to practice building a full-featured React app with real-world API integration, TypeScript, and professional error handling.

---

## Live Demo

[**View Live Demo**](https://weather-dashboard-v2-omega.vercel.app/)

---

## Features

- Search weather by city name
- Temperature in Celsius and Fahrenheit
- Wind speed display
- Humidity percentage
- Chance of rain
- Fully responsive design
- Real-time API integration
- TypeScript type safety

---

## Screenshots

| Home Page | Search Result |
| :---: | :---: |
| ![Home Page](./src/assets/screenshots/weather-dashboard-loaded.png) | ![Paris Result](./src/assets/screenshots/weather-dashboard-paris.png) |

---

## Tech Stack

| Technology | Purpose |
|------------|---------|
| React 18 | UI Framework |
| TypeScript | Type Safety |
| Tailwind CSS | Styling |
| Vite | Build Tool |
| WeatherAPI | Weather Data |
| API-Ninjas | City Coordinates |

---

## APIs Used

### API-Ninjas
- **Purpose:** Get latitude and longitude from city name
- **Documentation:** [api-ninjas.com](https://api-ninjas.com/)
- **Free Tier:** 3000 requests/month

### WeatherAPI
- **Purpose:** Fetch current weather data
- **Documentation:** [weatherapi.com](https://www.weatherapi.com/)
- **Free Tier:** 1,000,000 requests/month

---

## Environment Variables

Create a `.env` file in the root directory:

| Variable | Purpose | Where to Get |
|----------|---------|--------------|
| `VITE_WEATHER_API_KEY` | WeatherAPI key | [weatherapi.com](https://www.weatherapi.com/) |
| `VITE_COORDINATES_API_KEY` | API-Ninjas key | [api-ninjas.com](https://api-ninjas.com/) |

---

## Installation

### Prerequisites
- Node.js (v16.0.0 or higher)
- npm or yarn or pnpm

### Steps

**1. Clone the repository**
```bash
git clone https://github.com/kaleablemmadev/kaleab-dev-portfolio.git
cd kaleab-dev-portfolio/02_CODING_PORTFOLIO/weather-dashboard
```

**2. Install dependencies**
```bash
npm install
```
or
```bash
yarn install
```

**3. Set up environment variables**
```bash
cp .env.example .env
```
Then add your API keys to the `.env` file.

**4. Run the development server**
```bash
npm run dev
```
or
```bash
yarn dev
```

**5. Open your browser**
Navigate to `http://localhost:5173`

---

## Project Structure

```
weather-dashboard/
├── src/
│   ├── assets/
│   │   └── screenshots/    
│   ├── App.tsx             
│   ├── App.css             
│   ├── index.css           
│   └── main.tsx            
├── public/
├── .env                    
├── index.html              
├── package.json            
├── tailwind.config.js      
├── postcss.config.js       
└── README.md               
```

---

## What I Learned

Building this project taught me:

- **API Integration**: Fetching data from multiple APIs with proper error handling.
- **TypeScript**: Defining interfaces for type-safe state and props.
- **State Management**: Using `useState` and `useEffect` effectively.
- **Error Handling**: Graceful fallbacks for API failures and user-friendly error messages.
- **Tailwind CSS**: Building responsive, mobile-first layouts without custom CSS.
- **Environment Variables**: Securing API keys in `.env` files.
- **Deployment**: Deploying a React app to Vercel with environment variables.

---

## Related Articles

- [Understanding useState in React – A Beginner's Guide](https://dev.to/kaleablemmadev/usestate-in-react-a-beginners-guide-1j8i)

---

## Future Improvements

- [ ] 5-day weather forecast
- [ ] Unit toggle (Celsius/Fahrenheit)
- [ ] Recent search history (localStorage)
- [ ] Weather alerts for severe conditions
- [ ] Weather icons based on condition
- [ ] Dark/Light theme toggle

---

## Connect With Me

- [GitHub](https://github.com/kaleablemmadev)
- [LinkedIn](https://www.linkedin.com/in/kaleab-lemma-49b523416/)
- [Dev.to](https://dev.to/kaleablemmadev)

---