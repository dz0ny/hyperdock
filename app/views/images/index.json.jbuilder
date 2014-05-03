json.array!(@images) do |image|
  json.extract! image, :id, :name, :description, :docker_index
  json.url image_url(image, format: :json)
end
