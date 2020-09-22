class ResultsFacade
  def initialize
    @geocoding ||= GeocodingService.new
    @open_weather ||= OpenWeatherService.new
    @pixabay ||= PixabayService.new
  end

  def get_location(city_state)
    json = @geocoding.location_search(city_state)[:results][0]
    details = {
      coordinates: json[:locations][0][:latLng],
      city: json[:locations][0][:adminArea5],
      state: json[:locations][0][:adminArea3]
    }
    Location.new(details)
  end

  def get_forecast(city_state)
    coordinates = get_location(city_state).coordinates
    json = @open_weather.one_call(coordinates, 'minutely', 'imperial')
    Forecast.new(json)
  end

  def get_image(keywords)
    json = @pixabay.search_images(keywords)
    if json[:hits].count > 1
      index = rand(json[:hits].count - 1)
    elsif json[:hits].count == 1
      index = 0
    else
      return []
    end
    image_data = json[:hits][index]
    Image.new(image_data)
  end

  def get_trip_info(trip_params)
    json = @geocoding.directions_search(trip_params[:origin], trip_params[:destination])
    trip = RoadTrip.new(json)
    hour_index = trip.time_in_seconds.fdiv(3600).round(0) - 1
    forecast = get_forecast(trip_params[:destination])
    temp = forecast.next_48_hours[hour_index].temp
    weather = forecast.next_48_hours[hour_index].description
    trip.arrival_forecast[:temp] ||= temp
    trip.arrival_forecast[:weather] ||= weather
    trip
  end
end
