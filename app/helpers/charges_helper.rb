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
    #Grab the first paid order date from the database
    start_date=Order.minimum(:paid_at).try(:beginning_of_month).try(:to_date)
    #If we don't have any paid orders, quit no
    return {} if start_date.nil?
    #then the last
    end_date=Order.maximum(:paid_at).to_date
    #Set up our date range to be all months between the two
    #where day==1 means the first day of the month
    date_range=(start_date..end_date).select{|d| d.day==1}
    Hash(
      from_date: date_range.map(&:inspect),
      to_date: date_range.map{ |d| d.end_of_month.inspect }
      )
  end
end
