class Cost < ActiveRecord::Base
  belongs_to :costable, polymorphic: true, inverse_of: :cost
  belongs_to :currency

  validates :costable_id, presence: true, uniqueness: {scope: :costable_type}, unless: :costable_new?
  validates :currency, presence: true
  validates :value, presence: true, numericality: {only_integer: true}

  private
    def costable_new?
      #stolen from stack overflow to skip this validation if the parent item is new
      if new_record? and !costable and costable_type
        costable=nil
        ObjectSpace.each_object(costable_type.constantize) do |o|
          costable=o if o.cost==self unless costable
        end
      end
      costable
    end
end
