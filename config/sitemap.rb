# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = "https://www.snowschoolers.com"

SitemapGenerator::Sitemap.create do
  # Put links creation logic here.
  #
  # The root path '/' and sitemap index file are added automatically for you.
  # Links are added to the Sitemap in the order they are specified.
  #
  # Usage: add(path, options={})
  #        (default options are used if you don't specify)
  #
  # Defaults: :priority => 0.5, :changefreq => 'weekly',
  #           :lastmod => Time.now, :host => default_host
  #
  # Examples:
  #
  # Add '/articles'
  #
  #   add articles_path, :priority => 0.7, :changefreq => 'daily'
  #
  # Add all articles:
  #
  #   Article.find_each do |article|
  #     add article_path(article), :lastmod => article.updated_at
  #   end

  add '/apply', :priority => 0.9
  add '/browse', :priority => 0.8
  add '/index', :priority => 0.8
  add '/lessons/new', :priority => 1.0
  add '/new_request/:id', :priority => 0.9
  add blogs_path, :priority => 0.9
  add instructors_path, :priority => 0.9
  Blog.find_each do |blog|
      add blog_path(blog), :lastmod => blog.updated_at
    end
  Instructor.find_each do |instructor|
      add instructor_path(instructor), :lastmod => instructor.updated_at, :priority => 0.7
    end

end
