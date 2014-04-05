class Order < ActiveRecord::Base
  belongs_to :user, inverse_of: :orders
  has_many :line_items, inverse_of: :order
  has_many :products, through: :line_items, inverse_of: :orders

  
  validates :user, presence: true, if:  -> { status and status!="cart" }
  validates :line_items, presence: {message: "can't process blank order"}, if:  -> { status and status!="cart" }

  accepts_nested_attributes_for :line_items, allow_destroy: true

  enum status: {cart: 0, checkout: 10, placed: 20, paid: 30, dispatched: 40, cancelled: 100}

  before_save :pre_save

  def costs
    line_items.group_by(&:currency).map do |currency, items|
      Hash(currency: currency, cost: items.map(&:cost).sum)
    end if line_items.any?
  end

  def self.pending
    where(status: [self.statuses[:placed], self.statuses[:paid]])
  end


  private 
    def pre_save
      self.status||=:cart
      self.type=((status=="cart") ? "Cart" : nil) if status_changed?
    end
end
