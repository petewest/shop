class Order < ActiveRecord::Base
  belongs_to :user, inverse_of: :orders
  has_many :line_items, inverse_of: :order
  has_many :products, through: :line_items, inverse_of: :orders
  
  validates :user, presence: true

  enum status: [:cart, :placed, :paid, :dispatched]

  before_save {self.status||=:cart}

  def self.pending
    where(status: [self.statuses[:placed], self.statuses[:paid]])
  end
end
