json.extract! product_calendar, :id, :product_id, :price, :date, :status, :created_at, :updated_at
json.url product_calendar_url(product_calendar, format: :json)