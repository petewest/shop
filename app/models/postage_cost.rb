class PostageCost < ActiveRecord::Base
  include Costable

  validates :from_weight, presence: true, numericality: {greater_than_or_equal_to: 0}
  validates :to_weight, presence: true, numericality: {greater_than: :from_weight}
  validates :unit_cost, presence: true, numericality: true
  validates :currency, presence: true

  validate :no_overlap

  def self.for_weight(weight)
    where(
      arel_table[:from_weight].lt(weight)
    ).where(
      arel_table[:to_weight].gteq(weight)
    ).first
  end

  private
    def no_overlap
      #check for any overlapping records
      at=self.class.arel_table
      check=self.class.where(
        at[:to_weight].gt(from_weight)
      ).where(
        at[:from_weight].lt(to_weight)
      )
      check=check.where(at[:id].not_eq(id)) if persisted?
      errors[:base] << "Overlaps other postage boundaries" if check.any? 
    end
end
