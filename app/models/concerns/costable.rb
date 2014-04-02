module Costable
  extend ActiveSupport::Concern
  included do
    has_one :cost, as: :costable

    accepts_nested_attributes_for :cost

    after_initialize ->(i) { build_cost if cost.nil? }
  end
end
