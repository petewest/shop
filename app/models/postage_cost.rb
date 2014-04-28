class PostageCost < ActiveRecord::Base
  include Costable
  belongs_to :postage_service

  validates :from_weight, presence: true
  validates :from_weight, numericality: {greater_than_or_equal_to: 0}, if: -> { from_weight.present? }
  validates :to_weight, presence: true
  validates :to_weight, numericality: {greater_than: :from_weight}, if: -> { from_weight.present? and to_weight.present? }
  validates :unit_cost, presence: true, numericality: true
  validates :currency, presence: true
  validates :postage_service, presence: true

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
      ).where(
        postage_service: postage_service
      )
      check=check.where(at[:id].not_eq(id)) if persisted?
      errors[:base] << "Overlaps other postage boundaries" if check.any? 
    end
end
