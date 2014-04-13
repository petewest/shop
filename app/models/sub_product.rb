class SubProduct < Product
  validates :master_product, presence: true
end
