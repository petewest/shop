class Seller < User
  has_many :products, dependent: :destroy, inverse_of: :seller
  has_many :sub_products
  has_many :gift_card_products
end
