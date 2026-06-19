import { useState , useEffect } from 'react'
import './App.css'

interface WeatherDisplay {
  country: string;
  localTime: string;
  lastUpdated: string;
  tempC: number;
  tempF: number;
  windMph: number;
  humidity: number;
  chanceOfRain: string;
}

function App() {
  const [city, setCity] = useState<string>('');
  const [weather, setWeather] = useState<WeatherDisplay | null>(null);
  const [searchTerm, setSearchTerm] = useState<string>('');
  const [loading, setLoading] = useState<boolean>(false);
  const [error, setError] = useState<string | null>(null);

  const WEATHER_API_KEY = import.meta.env.VITE_WEATHER_API_KEY;
  const COORDINATES_API_KEY = import.meta.env.VITE_COORDINATES_API_KEY;

  useEffect(() => {
    if (!searchTerm) return;

    const fetchWeather = async (city: string) => {
      setLoading(true);
      setError(null);

      try {
        const response = await fetch(
          `https://api.api-ninjas.com/v1/city?name=${city}`,
          {
            method: 'GET',
            headers: {
              'x-api-key': COORDINATES_API_KEY,
            },
          }
        );

        if (!response.ok) {
          throw new Error('Unable to fetch coordinates');
        }

        const data = await response.json();
        if (data.length === 0) {
          throw new Error('City not found. Please check the spelling and try again.');
        }
        
        const lat = data[0].latitude;
        const lon = data[0].longitude;

        if (lat == null || lon == null) {
          throw new Error('City not found. Please check the spelling and try again.');
        }

        const q = `${lat},${lon}`;

        const weatherResponse = await fetch(
          `https://api.weatherapi.com/v1/current.json?key=${WEATHER_API_KEY}&q=${q}`
        );

        if (!weatherResponse.ok) {
          throw new Error('Unable to fetch weather');
        }

        const weatherData = await weatherResponse.json();

        const country = weatherData.location.country;
        const local_time = weatherData.location.localtime;
        const last_updated = weatherData.current.last_updated;
        const temp_c = weatherData.current.temp_c;
        const temp_f = weatherData.current.temp_f;
        const wind_mph = weatherData.current.wind_mph;
        const humidity = weatherData.current.humidity;
        const chance_of_rain = `${weatherData.current.chance_of_rain}%`;

        const cityWeatherData: WeatherDisplay = {
          country: country,
          localTime: local_time,
          lastUpdated: last_updated,
          tempC: temp_c,
          tempF: temp_f,
          windMph: wind_mph,
          humidity: humidity,
          chanceOfRain: chance_of_rain,
        }

        setWeather(cityWeatherData);
      } catch (err) {
        setError(err instanceof Error ? err.message : 'City not found');
      } finally {
        setLoading(false);
      }
    };

    fetchWeather(searchTerm);
  }, [searchTerm, COORDINATES_API_KEY, WEATHER_API_KEY]);

  const handleSearch = () => {
    if (city.trim()) {
      setSearchTerm(city.trim());
    }
  };

  return (
    <div className="justify-center items-center flex flex-col gap-6 p-6">
      <h1 className="text-4xl font-bold">Weather Dashboard</h1>
      <div className="flex flex-col gap-1.5">
        <div className="flex items-center gap-4">
          <input
            type="text"
            value={city}
            onChange={(e) => setCity(e.target.value)}
            placeholder="Enter city name"
            className="border border-gray-300 rounded-md px-4 py-2 focus:outline-none focus:ring-2 focus:ring-orange-500"
          />
          <button onClick={handleSearch} className="bg-orange-700 text-white px-4 py-2 rounded-md">
            Search
          </button>
        </div>
        <p className="text-sm text-gray-400"><span className="text-orange-600">City:</span> {city}</p>
      </div>

      {loading && <p>Loading weather data...</p>}
      {error && <p style={{ color: 'red' }}>Error: {error}</p>}

      {weather && (
        <>
          <div className="flex flex-wrap justify-between gap-20">
            <div className="flex flex-col min-w-[300px]">
              <h3 className="text-3xl mb-4 font-bold text-orange-700">Geographical Information</h3>
              <p>Country: {weather.country}</p>
              <p>Local Time: {weather.localTime}</p>
            </div>

            <div className="flex flex-col min-w-[300px]">
              <h3 className="text-3xl font-bold text-orange-700">Weather Information</h3>
              <p className="text-base font-bold mb-4 text-orange-300">(last updated at {weather.lastUpdated})</p>
              <p>Temperature: {weather.tempC}°C / {weather.tempF}°F</p>
              <p>Wind Speed: {weather.windMph} mph</p>
              <p>Humidity: {weather.humidity}%</p>
              <p>Chance of Rain: {weather.chanceOfRain}</p>
            </div>
          </div>
        </>
      )}
    </div>
  )
}

export default App
