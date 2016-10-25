json.array!(@reviews) do |review|
  json.extract! review, :id, :instructor_id, :lesson_id, :reviewer_id, :rating, :review
  json.url review_url(review, format: :json)
end
