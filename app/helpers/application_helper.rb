module ApplicationHelper
  def title(t)
    "Shop!" + (t.blank? ? "" : " | #{t}")
  end

  def seller_actions(&block)
    html=%Q{<div class="seller_actions">
      <h4>Seller actions</h4>
      <div class="btn-group-vertical">
    }
    html<<capture(&block)
    html<<%Q{</div></div>}
    html.html_safe
  end
end
