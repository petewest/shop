class SubProduct < Product
  validates :master_product, presence: true

  #Treat this as if it were a "product" when determining routes, actions, etc
  def self.model_name
    Product.model_name
  end
end
