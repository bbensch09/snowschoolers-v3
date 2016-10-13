json.array!(@products) do |product|
  json.extract! product, :id, :name, :price, :location_id, :calendar_period
  json.url product_url(product, format: :json)
end
