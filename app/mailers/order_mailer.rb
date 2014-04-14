class OrderMailer < ActionMailer::Base
  default from: "from@example.com"

  def confirmation_email(user, order)
    @user=user
    @order=order
    mail(to: @user.email, from: Seller.pluck(:email).first,subject: "Order confirmation #{order.id}")
  end
end
