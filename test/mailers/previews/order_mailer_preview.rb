# Preview all emails at http://localhost:3000/rails/mailers/order_mailer
class OrderMailerPreview < ActionMailer::Preview
  def confirmation
    OrderMailer.confirmation_email(Order.first)
  end
  def dispatch
    OrderMailer.dispatch_email(Order.first)
  end
  def cancel
    OrderMailer.cancel_email(Order.paid.first)
  end
  def cancel_seller
    OrderMailer.cancel_email_seller(Order.paid.first)
  end
  def gift_card_confirmation
    OrderMailer.confirmation_email(GiftCard.where.not(allocation_id: nil).first.allocation.line_item.order)
  end
end
