class Seller < User
  has_many :products, dependent: :destroy, inverse_of: :seller
  has_many :sub_products
end
