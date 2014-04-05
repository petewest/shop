module Costable
  extend ActiveSupport::Concern
  included do
    belongs_to :currency

    validates :currency, presence: true
    validates :cost, presence: true, numericality: true

  end
end
