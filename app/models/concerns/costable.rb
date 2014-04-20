module Costable
  extend ActiveSupport::Concern
  included do
    belongs_to :currency
  end
  def cost
    unit_cost
  end

end
