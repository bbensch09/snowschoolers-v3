json.extract! blog, :id, :author, :title, :published, :content, :created_at, :updated_at
json.url blog_url(blog, format: :json)