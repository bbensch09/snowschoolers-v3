json.array!(@lesson_actions) do |lesson_action|
  json.extract! lesson_action, :id, :lesson_id, :instructor_id, :action
  json.url lesson_action_url(lesson_action, format: :json)
end
