class OrderMailer < ActionMailer::Base
  default from: Rails.application.secrets.from_email, bcc: Seller.where(bcc_on_email: true).pluck(:email)

  def confirmation_email(order)
    @order=order
    @user=@order.user
    mail(to: @user.email, subject: "Order confirmation ##{@order.id}")
  end

  def dispatch_email(order)
    @order=order
    @user=@order.user
    mail(to: @user.email, subject: "Order ##{@order.id} dispatched")
  end
end
