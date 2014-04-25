class ChargesController < ApplicationController
  before_action :signed_in_seller
  before_action :find_charge, only: [:refund]

  def index
    begin
      # Grab the charges direct from Stripe
      @charges=Stripe::Charge.all
      #convert them to an array instead of a Stripe::List
      @charges=@charges.to_a
    rescue Stripe::AuthenticationError => e
      flash[:danger]="Error authenticating with Stripe.  Check your API key."
      return
    end
    flash[:warning]="No charges found" and return if @charges.empty?
    # find the orders that correspond to these stripe refs
    @orders=Order.where(stripe_charge_reference: @charges.map(&:id))
    # match charges to orders
    @charges_and_orders=@charges.map do |ch|
      Hash(
        charge: ch,
        order: @orders.find{ |o| o.stripe_charge_reference==ch.id }
      )
    end
  end

  def refund
    if @charge.refund
      flash[:success]="Charge refunded!"
    else
      flash[:danger]="Charge refund failed"
    end
    redirect_to charges_url
  end

  private
    def find_charge
      @charge=Stripe::Charge.retrieve(params[:id])
    end
end
