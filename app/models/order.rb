class Order < ActiveRecord::Base
  belongs_to :user, inverse_of: :orders
  has_many :line_items, inverse_of: :order, dependent: :destroy
  has_many :products, through: :line_items, inverse_of: :orders
  belongs_to :delivery, class_name: "OrderAddress", dependent: :destroy
  belongs_to :billing, class_name: "OrderAddress", dependent: :destroy

  #For anything not in "cart" status
  #So all validations that make sure it's an order instead of a shopping cart
  with_options if:  -> { status and status!="cart" } do |non_cart|
    non_cart.validates :user, presence: true
    non_cart.validates :line_items, presence: {message: "can't process blank order"}
    non_cart.validates :delivery, presence: true
    non_cart.validates :billing, presence: true
  end

  #When switching to "placed" status we want to run some extra
  #process to check stock for validation, then allocate stock after successful save
  with_options if: -> { status_changed? and status=="placed" } do |placed|
    placed.validate :stock_check
    placed.after_save :decrement_stock
  end

  accepts_nested_attributes_for :line_items, allow_destroy: true
  accepts_nested_attributes_for :delivery, allow_destroy: true
  accepts_nested_attributes_for :billing, allow_destroy: true

  enum status: {cart: 0, checkout: 10, placed: 20, paid: 30, dispatched: 40, cancelled: 100}

  before_create -> {self.status||=:cart}

  before_save :pre_save

  default_scope -> {includes(line_items: [:product, :currency])}

  #Total order cost, grouped by currency
  def costs
    calculate_costs(*line_items)
  end

  #Total order costs, with postage cost included
  def costs_with_postage
    calculate_costs(*line_items, postage_cost)
  end

  def self.pending
    where(status: [self.statuses[:placed], self.statuses[:paid]])
  end

  #Find the total weight by summing the weights of each line item
  #(which is product weight * quantity)
  def total_weight
    line_items.map(&:weight).sum
  end

  #Find the postage_cost item for this total_weight
  def postage_cost
    PostageCost.for_weight(total_weight)
  end


  private 
    def pre_save
      self.type=((status=="cart") ? "Cart" : nil) if status_changed?
      true
    end

    def stock_check
      errors[:base]<<"Not enough stock" if !line_items.all?(&:stock_check)
    end

    def decrement_stock
      line_items.all?(&:take_stock)
    end

    def calculate_costs(*these_items)
        these_items.select{|i| i.respond_to? :currency}.group_by(&:currency).map do |currency, items|
          Hash(currency: currency, cost: items.map(&:cost).sum)
        end if these_items.any?
    end
end
