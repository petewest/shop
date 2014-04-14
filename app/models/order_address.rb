class OrderAddress < ActiveRecord::Base
  belongs_to :source_address, class_name: "Address"
  has_one :order

  validates :source_address, presence: true

  after_save :copy_address

  def copy_address
    self.address=source_address.address
    self
  end
end
