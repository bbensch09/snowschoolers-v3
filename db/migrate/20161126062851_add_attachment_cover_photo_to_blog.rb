class AddAttachmentCoverPhotoToBlog < ActiveRecord::Migration[5.0]
  def self.up
    change_table :blogs do |t|
      t.attachment :cover_photo
    end
  end

  def self.down
    remove_attachment :blogs, :cover_photo
  end

end
