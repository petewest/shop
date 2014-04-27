module ChargesHelper
  def render_result(results)
    html=""
    results.each do |check, answer|
      html<<%Q{<div class="col-md-12">}
      case check
      when Symbol
        html<<check.to_s.titleize
      when String
        html<<check.titleize
      when Currency
        html<<check.iso_code
      else
        html<<check.class.to_s.titleize
      end
      html<<%Q{: }
      case answer
      when Hash
        html<<render_result(answer)
      when true
        html<<%Q{<span class="glyphicon glyphicon-ok"></span>}
      else
        html<<%Q{<span class="glyphicon glyphicon-remove"></span>}
      end
      html<<%Q{</div>}
    end
    html.html_safe
  end

  def charges_filter
    #Grab the first paid order from the database
    first_paid_order=Order.where.not(paid_at: nil).order(paid_at: :desc).first
    #If we don't have any paid orders, quit no
    return {} if first_paid_order.nil?
    #then the last
    last_paid_order=Order.where.not(paid_at: nil).order(paid_at: :desc).last
    #Work out our start & end dates
    start_date=first_paid_order.paid_at.beginning_of_month.to_date
    end_date=last_paid_order.paid_at.to_date
    #Set up our date range to be all months between the two
    date_range=(start_date..end_date).select{|d| d.day==1}
    Hash(
      from_date: date_range.map(&:inspect),
      to_date: date_range.map{ |d| d.end_of_month.inspect }
      )
  end
end
