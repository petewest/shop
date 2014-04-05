module ApplicationHelper
  def title(t)
    "Shop!" + (t.blank? ? "" : " | #{t}")
  end

  def action_bar(item, options={}, &block)
    options[:class]||="action_bar"
    options[:title]||="Actions"
    html=%Q{<div class="#{options[:class]}">
      #{content_tag(:h4, options[:title])}
      <div class="btn-group-vertical">
    }
    html<<capture(&block) if block_given?
    html<<link_to("Edit", [:edit, item], class: "btn btn-default")
    html<<link_to("Delete", item, method: :delete, data: {confirm: "Are you sure you wish to delete this #{item.class.name.downcase}?"}, class: "btn btn-danger")
    html<<%Q{</div></div>}
    html.html_safe
  end

  def cost_to_currency(*items)
    items.map do |item|
      currency=item[:currency] || item.currency
      cost=item[:cost] || item.cost
      number_to_currency(cost, unit: currency.symbol, precision: currency.decimal_places)
    end.join
  end

  def css_id(item)
    "#{item.class.name.parameterize}_#{item.new_record? ? 'new' : item.id }"
  end
end
