# Preview all emails at http://localhost:3000/rails/mailers/order_mailer
class OrderMailerPreview < ActionMailer::Preview
  def confirmation
    OrderMailer.confirmation_email(Order.first)
  end
  def dispatch
    OrderMailer.dispatch_email(Order.first)
  end
end
