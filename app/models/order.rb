class Order < ActiveRecord::Base
  belongs_to :user, inverse_of: :orders
  validates :user, presence: true

  enum status: [:cart, :placed, :paid, :dispatched]

  before_save {self.status||=:cart}
end
