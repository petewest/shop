class OrdersController < ApplicationController
  before_action :signed_in_user
  before_action :order_from_params, only: [:show, :pay, :update]

  def index
    @orders=current_user.orders.includes(line_items: [:product, :currency]).order(status: :asc).all
  end

  def show
  end

  def set_current
    @order=current_user.carts.find_by(id: params[:id])
    if @order
      flash[:success]="Previous cart resumed"
      self.current_cart=@order
    else
      flash[:warning]="Cart not found"
    end
    redirect_to checkout_url and return if params[:submit]=="Checkout"
    redirect_to cart_url
  end

  def pay
    if !@order.placed?
      flash[:warning]="Please confirm order before trying to pay"
      redirect_to checkout_url
      return
    end
  end

  def update
    Stripe.api_key = Rails.application.secrets.stripe_secret_key

    # Get the credit card details submitted by the form
    token = params[:stripeToken]

    if token.empty?
      flash[:warning]="Missing payment data, please try again"
      redirect_to pay_order_path(@order)
      return
    end

    begin
      #This won't work if there are multiple currencies in the order
      #as the token can only be used once.
      #TODO think about this.  Maybe validate line_items to make sure it's the same currency?
      #Or combine multiple currencies to the charge currency, but then have to keep FX rates up to date
      #Leave as-is for now
      charges=@order.costs_with_postage.map do |cost|
        Stripe::Charge.create(
          amount: cost[:cost],
          currency: cost[:currency].iso_code.downcase,
          card: token,
          description: "Order: ##{@order.id}: #{@order.user.email}"
        )
      end
    rescue Stripe::CardError => e
      # Since it's a decline, Stripe::CardError will be caught
      body = e.json_body
      err  = body[:error]

      flash[:warning]="Card failed verification: #{err[:message]}"

    rescue Stripe::InvalidRequestError => e
      # Invalid parameters were supplied to Stripe's API
      flash[:warning]="Invalid payment request, please contact seller"
    rescue Stripe::AuthenticationError => e
      # Authentication with Stripe's API failed
      # (maybe you changed API keys recently)
      flash[:warning]="Failed to authenticate with payment system, please contact seller"
    rescue Stripe::APIConnectionError => e
      # Network communication with Stripe failed
      flash[:warning]="Failed to contact payment system, please contact seller"
    rescue Stripe::StripeError => e
      # Display a very generic error to the user
      flash[:warning]="Unknown error, please contact seller"
    end
    redirect_to pay_order_path(@order) and return if flash[:warning].present?
    @order.stripe_charge_reference=charges.map(&:id).join(", ")
    @order.status=:paid
    if @order.save
      flash[:success]="Thank you for your order!"
    else
      flash[:warning]="Error processing order, please contact seller"
    end
    redirect_to order_path(@order)
  end


  private
    def order_from_params
      @order=current_user.orders.find(params[:id])
    end

end
