class Cart < Order
  validates :cart_token, presence: true, uniqueness: true

  before_validation :create_token


  #Our cart token just needs to be random enough that users won't try and guess other peoples carts
  #we won't encrypt this like we do the session remember token as it's not as important, plus it 
  #means we can re-use the token again if the user logs in from a different PC
  def self.new_cart_token
    SecureRandom.urlsafe_base64
  end


  private
    def create_token
      self.cart_token||=Cart.new_cart_token
    end
end
