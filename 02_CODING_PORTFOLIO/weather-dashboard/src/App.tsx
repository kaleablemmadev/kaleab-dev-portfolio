import { useState , useEffect } from 'react'
import './App.css'

function App() {
  const [city, setCity] = useState<string>('');
  const [weather, setWeather] = useState<(string | number)[] | null>(null);
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
        const lat = data[0].latitude;
        const lon = data[0].longitude;

        if (lat == null || lon == null) {
          throw new Error('City not found');
        }

        const q = `${lat},${lon}`;

        const weatherResponse = await fetch(
          `http://api.weatherapi.com/v1/current.json?key=${WEATHER_API_KEY}&q=${q}`
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

        const cityWeatherData = [
          country,
          local_time,
          last_updated,
          temp_c,
          temp_f,
          wind_mph,
          humidity,
          chance_of_rain,
        ];

        setWeather(cityWeatherData);
      } catch (err) {
        setError(err instanceof Error ? err.message : 'City not found');
      } finally {
        setLoading(false);
      }
    };

    fetchWeather(city);
  }, [searchTerm]);

  const handleSearch = () => {
    if (city.trim()) {
      setSearchTerm(city.trim());
    }
  };

  const [country, local_time , last_updated , temp_c , temp_f , wind_mph , humidity , chance_of_rain] = weather || [];

  return (
    <div className="pt-3">
      <h1>Weather Dashboard</h1>
      <p>City: {city}</p>
      <input
        type="text"
        value={city}
        onChange={(e) => setCity(e.target.value)}
        placeholder="Enter city name"
      />
      <button onClick={handleSearch}>Search</button>

      {loading && <p>Loading weather data...</p>}
      {error && <p style={{ color: 'red' }}>Error: {error}</p>}

      {weather && (
        <>
          <h3>Geographical Information</h3>
          <p>Country: {country}</p>
          <p>Local Time: {local_time}</p>
          
          <h3>Weather Information <span>(last updated at {last_updated})</span></h3>
          <p>Temperature: {temp_c}°C / {temp_f}°F</p>
          <p>Wind Speed: {wind_mph} mph</p>
          <p>Humidity: {humidity}%</p>
          <p>Chance of Rain: {chance_of_rain}</p>
        </>
      )}
    </div>
  )
}

export default App
