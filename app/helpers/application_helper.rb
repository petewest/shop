module ApplicationHelper
  def title(t)
    "Shop!" + (t.blank? ? "" : " | #{t}")
  end

  def action_bar(item, options={}, &block)
    default_options={class: "action_bar", title: "Actions", direction: "vertical", allow_edit: true, allow_delete: true}
    default_options.merge!(options)
    html=%Q{<div class="#{default_options[:class]}">}
    html+=%Q{#{content_tag(:h4, default_options[:title])}} if !default_options[:title].blank?
    html+=%Q{<div class="btn-group#{default_options[:direction]=="vertical" ? "-vertical" : ""}">}
    html<<capture(&block) if block_given?
    html<<link_to("Edit", [:edit, item], class: "btn btn-default") if default_options[:allow_edit]
    html<<link_to("Delete", item, method: :delete, data: {confirm: "Are you sure you wish to delete this #{item.class.name.downcase}?"}, class: "btn btn-danger") if default_options[:allow_delete]
    html<<%Q{</div></div>}
    html.html_safe
  end

  def cost_to_currency(*items)
    items.select{|i| i}.map do |item|
      currency=item[:currency] || item.currency
      cost=(item[:cost] || item.cost) / (10.0**currency.decimal_places)
      number_to_currency(cost, unit: currency.symbol, precision: currency.decimal_places)
    end.join
  end

  def css_id(item)
    "#{item.class.name.parameterize}_#{item.new_record? ? 'new' : item.id }"
  end
end
