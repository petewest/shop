class Seller < User
  has_many :products, dependent: :destroy
end
