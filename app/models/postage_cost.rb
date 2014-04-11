class PostageCost < ActiveRecord::Base
  belongs_to :currency

  validates :from_weight, presence: true, numericality: {greater_than_or_equal_to: 0}
  validates :to_weight, presence: true, numericality: {greater_than: :from_weight}
  validates :cost, presence: true, numericality: true
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
      at=self.class.arel_table
      #errors[:base] << "Overlaps other postage boundaries" if self.class.where(
      #).any?
    end
end
