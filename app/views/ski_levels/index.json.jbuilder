json.array!(@ski_levels) do |ski_level|
  json.extract! ski_level, :id, :name, :value
  json.url ski_level_url(ski_level, format: :json)
end
