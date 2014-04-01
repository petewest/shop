class Image < ActiveRecord::Base
  belongs_to :product, inverse_of: :images

  validates :product, presence: true

  has_attached_file :image, styles: {
    thumb: '100x100>',
    preview: '200x200>',
    medium: '400x400>'
  }

  def self.main
    where(main: true)
  end

  validates_attachment_content_type :image, content_type: /\Aimage\/.*Z/
end
