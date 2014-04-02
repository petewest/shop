class Cost < ActiveRecord::Base
  belongs_to :costable, polymorphic: true, inverse_of: :cost
  belongs_to :currency

  validates :costable_id, uniqueness: {scope: :costable_type}
  validates :currency, presence: true
  validates :value, presence: true, numericality: {only_integer: true}

  before_save :validate_costable

  private
    def validate_costable
      if !costable
        errors[:costable]<<"can't be blank"
        false
      end
    end
end
