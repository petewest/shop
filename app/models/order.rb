class Order < ActiveRecord::Base
  include Costable
  ## Relationships
  belongs_to :user, inverse_of: :orders
  has_many :line_items, inverse_of: :order, dependent: :destroy
  has_many :allocations, through: :line_items
  has_many :products, through: :line_items, inverse_of: :orders
  belongs_to :delivery, class_name: "OrderAddress", dependent: :destroy
  belongs_to :billing, class_name: "OrderAddress", dependent: :destroy
  belongs_to :postage_cost
  belongs_to :postage_service


  ## Validations

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
    placed.validates :postage_cost, presence: {message: "missing, please contact the seller"}
    placed.after_save :decrement_stock
  end

  validate :check_flow, if: -> {status_changed? and persisted?}

  accepts_nested_attributes_for :line_items, allow_destroy: true
  accepts_nested_attributes_for :delivery, allow_destroy: true
  accepts_nested_attributes_for :billing, allow_destroy: true

  enum status: {cart: 0, checkout: 10, placed: 20, paid: 30, dispatched: 40, cancelled: 100}


  ## Callbacks

  before_create -> {self.status||=:cart}
  before_save :pre_save

  ## Scopes

  scope :index_scope,  -> { includes(:currency, line_items: [:product, :currency]).order(updated_at: :desc) }
  def self.pending
    where(status: [self.statuses[:placed], self.statuses[:paid]])
  end


  ## Methods

  #Which status flows are allowed?
  #Class method for all allowed
  def self.allowed_status_flows
    {
      cart: [:placed, :cancelled],
      placed: [:paid, :dispatched, :cancelled],
      paid: [:dispatched, :cancelled],
      cancelled: :cart
    }
  end
  #Instance method for allowed from this status
  def allowed_status_flows(start=nil)
    start||=status
    permitted=*self.class.allowed_status_flows[start.to_sym]
  end

  #Find the total weight by summing the weights of each line item
  #(which is product weight * quantity)
  def total_weight
    line_items.map(&:weight).sum
  end

  ## These functions all replace the ones added by activerecord
  #  they'll call the AR function first, but if that returns nil (no data saved in record)
  #  they'll calculate what the item should be from its sub items

  #Total order costs, with postage cost included
  def cost(recalculate=false)
    (!recalculate && super()) || (line_items.map(&:cost).sum + postage_cost.try(:cost).to_i)
  end

  #Find the postage_cost item for this total_weight
  def postage_cost(recalculate=false)
    #First we'll check if postage_cost on the model is nil
    (!recalculate && super()) || PostageCost.where(currency: currency).where(postage_service: postage_service).for_weight(total_weight)
  end

  #Find the currency of the order
  def currency(recalculate=false)
    (!recalculate && super()) || line_items.first.try(:currency)
  end

  #Find the postage service to use
  def postage_service
    super || PostageService.default
  end


  # Reconcile this order with the charge
  def reconcile_charge(charge)
    recon_status=true if status.in?(%w(paid dispatched)) and charge.paid==true and charge.refunded!=true
    recon_status=true if status.in?(%w(cancelled)) and charge.refunded==true
    recon_status||=false
    Hash(
      currency: charge.currency.upcase==currency.iso_code.upcase,
      cost: charge.amount==cost,
      status: recon_status
      )
  end

  #fix all costs
  def fix_costs
    self.postage_cost=postage_cost(true)
    self.currency=currency(true)
    self.unit_cost=cost(true)
    self.postage_service=postage_service
  end

  #helper method to fix all costs and save
  def fix_costs!
    fix_costs
    save!
  end


  private 
    def pre_save
      if status_changed?
        #Check if we're switching to cart status, so change type to Cart
        self.type=((status=="cart") ? "Cart" : nil)
        #Record timestamps if order changes status
        self.send(status+"_at=", DateTime.now) if self.respond_to?(status+"_at=")
        #Release stock if an order has been cancelled
        line_items.all?(&:release_stock) if status=="cancelled"
        #fix a copy of the costs when the order gets placed
        fix_costs if status=="placed"
      end
      true
    end

    def stock_check
      errors[:base]<<"Not enough stock" if !line_items.all?(&:stock_check)
    end

    def decrement_stock
      line_items.all?(&:take_stock)
    end

    def check_flow
      permitted=allowed_status_flows(status_was)
      errors[:status]="cannot change from #{status_was} to #{status}" if !permitted.include? status.to_sym
    end
end
