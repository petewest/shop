class Order < ActiveRecord::Base
  belongs_to :user, inverse_of: :orders

  enum status: [:cart, :placed, :paid, :dispatched]

  before_save {self.status||=:cart}
end
