class PixabayService
  include Serviceable

  def search_images(keywords)
    response = conn.get do |req|
      req.params[:q] = keywords
    end
    get_json(response)
  end

  private

  def get_json(response)
    JSON.parse(response.body, symbolize_names: true)
  end

  def conn
    url = "https://pixabay.com/api/"
    base_conn(url, "key", "PIXABAY_API_KEY")
  end
end
