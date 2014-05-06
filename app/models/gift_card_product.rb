class GiftCardProduct < Product
  def name
    self.class.model_name.human
  end
end
