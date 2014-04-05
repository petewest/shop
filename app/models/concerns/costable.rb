module Costable
  extend ActiveSupport::Concern
  included do
    belongs_to :currency
  end
  def cost
    unit_cost / 10.0**currency.try(:decimal_places).to_i
  end

end
