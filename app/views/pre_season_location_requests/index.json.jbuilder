json.array!(@pre_season_location_requests) do |pre_season_location_request|
  json.extract! pre_season_location_request, :id, :name
  json.url pre_season_location_request_url(pre_season_location_request, format: :json)
end
