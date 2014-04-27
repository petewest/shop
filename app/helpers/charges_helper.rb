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
    pretty_dates= -> (d) { d.to_date.inspect }
    # Calculate some dates using SQL-specific jazz
    case ActiveRecord::Base.connection
    # PG gives us 'date_trunc' as a function to strip away bits of a date we don't want
    when ActiveRecord::ConnectionAdapters::PostgreSQLAdapter
      start_dates=Order.where.not(paid_at: nil).select("DATE_TRUNC('month', paid_at) AS paid_at").group("DATE_TRUNC('month', paid_at)").map(&:paid_at)
    # if we don't know how to handle the current db, default to letting ruby do the hard work
    else
      start_dates=Order.where.not(paid_at: nil).pluck(:paid_at).map(&:beginning_of_month).uniq
    end
    Hash(
      from_date: start_dates.map(&pretty_dates),
      to_date: start_dates.map(&:end_of_month).map(&pretty_dates)
      )
  end
end
