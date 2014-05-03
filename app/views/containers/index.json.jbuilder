json.array!(@containers) do |container|
  json.extract! container, :id, :image_id, :status
  json.url container_url(container, format: :json)
end
