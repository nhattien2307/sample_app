class Micropost < ApplicationRecord
  belongs_to :user

  validates :user_id, presence: true
  validates :content, presence: true,
    length: {maximum: Settings.micropost.maximum_length}
  validate  :picture_size

  scope :recent_post, ->{order created_at: :desc}

  mount_uploader :picture, PictureUploader

  private

  # Validates the size of an uploaded picture.
  def picture_size
    return if picture.size <= Settings.picture.picture_size.megabytes
    errors.add(:picture, t("micropost.picture.max_size"))
  end
end
