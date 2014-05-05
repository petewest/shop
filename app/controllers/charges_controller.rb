class ChargesController < ApplicationController
  before_action :signed_in_seller
  before_action :find_charge, only: [:refund, :show]

  def index
    #collect date range from params, or use this last month
    @to_date=DateTime.parse(params[:to_date]).end_of_day if params[:to_date]
    @to_date||=DateTime.now.end_of_month
    @from_date=DateTime.parse(params[:from_date]).beginning_of_day if params[:from_date]
    @from_date||=DateTime.now.beginning_of_month
    #Set the params so we can use them later (in the filter checker)
    params[:to_date]=@to_date.to_date.inspect
    params[:from_date]=@from_date.to_date.inspect
    begin
      # Grab the charges direct from Stripe for this date period
      @charges=Stripe::Charge.all(created: { gte: @from_date.to_i, lte: @to_date.to_i })
      #convert them to an array instead of a Stripe::List
      @charges=@charges.to_a
    rescue Stripe::AuthenticationError => e
      flash[:danger]="Error authenticating with Stripe. #{e.message}"
      return
    rescue Stripe::APIConnectionError => e
      # Network communication with Stripe failed
      flash[:danger]="Failed to contact payment system: #{e.message}"
      return
    rescue Stripe::StripeError => e
      flash[:danger]="Stripe error: #{e.message}"
      return
    end
    flash[:warning]="No charges found" and return if @charges.nil? or @charges.empty?
    # find the orders that were paid during this date range
    @orders=Order.includes(:currency, line_items: :buyable).where(paid_at: @from_date..@to_date)
    # match charges to orders
    @charges_and_orders=@charges.map do |ch|
      order=@orders.find{ |o| o.stripe_charge_reference==ch.id }
      charge_and_order(ch, order)
    end
  end

  def refund
    if @order and params[:cancel]
      @order.cancelled!
      flash.now[:success]="Order cancelled. "
    end
    @charge.refund
    flash.now[:success]+="Charge refunded!"
  rescue Stripe::StripeError => e
    flash.now[:danger]=e.message
  rescue ActiveRecord::RecordInvalid => e
    flash.now[:danger]="Error cancelling order: #{e.message}"
  ensure
    @charge_and_order=charge_and_order(@charge, @order)
    respond_to do |format|
      format.html { flash.keep and redirect_to charges_url }
      format.js
    end
  end

  def show
    @charge_and_order=charge_and_order(@charge, @order)
  end

  private
    def find_charge
      @charge=Stripe::Charge.retrieve(params[:id])
      @order=Order.find_by_stripe_charge_reference(params[:id])
    rescue Stripe::StripeError => e
      flash.now[:warning]="Stripe error: #{e.message}"
      respond_to do |format|
        format.html { flash.keep and redirect_to charges_url }
        format.js { render partial: 'shared/refresh_flash'}
      end
    end

    def charge_and_order(charge, order)
      reconcile_result=order.reconcile_charge(charge) if order
      {
      charge: charge,
      order: order,
      reconcile_result: reconcile_result
      }
    end
end
