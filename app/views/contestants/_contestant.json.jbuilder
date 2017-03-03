json.extract! contestant, :id, :username, :hometown, :created_at, :updated_at
json.url contestant_url(contestant, format: :json)