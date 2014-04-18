class OrderMailer < ActionMailer::Base
  default from: Seller.pluck(:email).first, bcc: Seller.where(bcc_on_email: true).pluck(:email)

  def confirmation_email(order)
    @order=order
    @user=@order.user
    mail(to: @user.email, subject: "Order confirmation #{order.id}")
  end

  def dispatch_email(order)
    @order=order
    @user=@order.user
    mail(to: @user.email, subject: "Order dispatched")
  end
end
