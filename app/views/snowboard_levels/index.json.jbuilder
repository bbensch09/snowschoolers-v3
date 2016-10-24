json.array!(@snowboard_levels) do |snowboard_level|
  json.extract! snowboard_level, :id, :name, :value
  json.url snowboard_level_url(snowboard_level, format: :json)
end
