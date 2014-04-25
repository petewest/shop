class OrdersController < ApplicationController
  before_action :signed_in_user
  before_action :order_from_params, only: [:show, :pay, :update, :cancel]

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

    # Get the credit card details submitted by the form
    token = params[:stripeToken]

    if token.blank?
      flash[:warning]="Missing payment data, please try again"
      redirect_to pay_order_path(@order)
      return
    end

    #set status to paid here (won't get actioned until we save the record later)
    #in order to test for validity before attempting to create the charge
    #This shouldn't happen in the normal course of events but incase anyone tries
    #to POST to the page manually
    @order.status=:paid

    if !@order.valid?
      flash.now[:danger]="Could not process order"
      render 'pay'
      return
    end

    #Check to make sure this order doesn't already have a payment reference
    redirect_to order_path(@order), flash: {warning: "Order already paid"} and return if @order.stripe_charge_reference.present?

    #Actually create the charge in Stripes systems
    begin
      Stripe::Charge.create(
        amount: @order.cost,
        currency: @order.currency.iso_code.downcase,
        card: token,
        description: "Order: ##{@order.id}: #{@order.user.email}"
      )
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
    if @order.save
      flash[:success]="Thank you for your order!"
      OrderMailer.confirmation_email(@order).deliver
    else
      flash[:warning]="Error processing order, please contact seller"
    end
    redirect_to order_path(@order)
  end

  def cancel
    if @order.cancelled!
      flash[:success]="Order cancelled"
    else
      flash[:danger]="Could not cancel order"
    end
    redirect_to orders_path
  end


  private
    def order_from_params
      @order=current_user.orders.find(params[:id])
    end

end
