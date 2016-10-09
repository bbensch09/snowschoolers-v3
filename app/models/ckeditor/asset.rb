class Ckeditor::Asset < ActiveRecord::Base
  include Ckeditor::Orm::ActiveRecord::AssetBase
  include Ckeditor::Backend::Paperclip

  Rails.application.config.assets.precompile += %w( ckeditor/* )

end
