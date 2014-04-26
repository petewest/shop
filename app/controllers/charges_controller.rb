class ChargesController < ApplicationController
  before_action :signed_in_seller
  before_action :find_charge, only: [:refund]

  def index
    #collect date range from params, or use this last month
    @to_date=DateTime.parse(params[:to_date]) if params[:to_date]
    @to_date||=DateTime.now
    @from_date=DateTime.parse(params[:from_date]) if params[:from_date]
    @from_date||=@to_date-1.month
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
    @orders=Order.includes(:currency, line_items: [product: [:master_product]]).where(paid_at: @from_date..@to_date)
    #convert to an array so we can use Array's .delete() instead of ActiveRecord Relations :)
    @orders=@orders.to_a
    # match charges to orders
    @charges_and_orders=@charges.map do |ch|
      order=@orders.find{ |o| o.stripe_charge_reference==ch.id }
      if order
        reconcile=order.reconcile_charge(ch)
        @orders.delete(order)
      end
      Hash(
        charge: ch,
        order: order,
        reconcile_result: reconcile
      )
    end
  end

  def refund
    begin
      @charge.refund
    rescue Stripe::StripeError => e
      flash[:danger]="#{e.message}"
    else
      flash[:success]="Charge refunded!"
    end
    redirect_to charges_url
  end

  private
    def find_charge
      @charge=Stripe::Charge.retrieve(params[:id])
    rescue Stripe::StripeError => e
      @charge=nil
      flash[:warning]="Stripe error: #{e.message}"
      respond_to do |format|
        format.html { redirect_to charges_url }
        format.js { render partial: 'shared/refresh_flash'}
      end
    end
end
