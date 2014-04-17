class OrderMailer < ActionMailer::Base
  default from: "from@example.com", bcc: Seller.where(bcc_on_email: true).pluck(:email)

  def confirmation_email(user, order)
    @user=user
    @order=order
    mail(to: @user.email, from: Seller.pluck(:email).first,subject: "Order confirmation #{order.id}")
  end
end
