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

    begin
      charges=@order.costs_with_postage.map do |cost|
        Stripe::Charge.create(
          amount: cost[:cost],
          currency: cost[:currency].iso_code.downcase,
          card: token,
          description: @order.user.email
        )
      end
    rescue Stripe::CardError => e
      # Since it's a decline, Stripe::CardError will be caught
      body = e.json_body
      err  = body[:error]

      flash[:warning]="Card failed verification: #{err[:message]}"

    rescue Stripe::InvalidRequestError => e
      # Invalid parameters were supplied to Stripe's API
    rescue Stripe::AuthenticationError => e
      # Authentication with Stripe's API failed
      # (maybe you changed API keys recently)
    rescue Stripe::APIConnectionError => e
      # Network communication with Stripe failed
    rescue Stripe::StripeError => e
      # Display a very generic error to the user, and maybe send
      # yourself an email
    rescue => e
      # Something else happened, completely unrelated to Stripe
    end
  end


  private
    def order_from_params
      @order=current_user.orders.find(params[:id])
    end

end
