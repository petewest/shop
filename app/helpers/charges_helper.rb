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
end
