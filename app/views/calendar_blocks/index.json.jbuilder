json.array!(@calendar_blocks) do |calendar_block|
  json.extract! calendar_block, :id, :instructor_id, :lesson_time_id, :status
  json.url calendar_block_url(calendar_block, format: :json)
end
