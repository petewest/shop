class GiftCardProduct < Product
  # override association class
  has_many :allocations, class_name: "GiftCardAllocation", foreign_key: "product_id"

  def name
    self.class.model_name.human
  end

end
