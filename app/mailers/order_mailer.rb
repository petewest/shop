class OrderMailer < ActionMailer::Base
  default from: Seller.pluck(:email).first, bcc: Seller.where(bcc_on_email: true).pluck(:email)

  def confirmation_email(user, order)
    @user=user
    @order=order
    mail(to: @user.email, subject: "Order confirmation #{order.id}")
  end

  def dispatch_email(user, order)
    @user=user
    @order=order
    mail(to: @user.email, subject: "Order dispatched")
  end
end
