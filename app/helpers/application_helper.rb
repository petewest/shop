module ApplicationHelper
  def title(t)
    "Shop!" + (t.blank? ? "" : " | #{t}")
  end

  def action_bar(item, options={}, &block)
    default_actions=[:edit, :delete]
    default_options={class: "action_bar", title: "Actions", vertical: true, dropdown: false}
    default_options.merge!(options)
    actions=default_actions - options[:except].to_a
    actions=*options[:only] if options[:only]
    link_class=(default_options[:dropdown] ? "" : "btn btn-default")
    html=%Q{<div class="#{default_options[:class]}#{ default_options[:dropdown] ? ' dropdown' : '' }">}
    if default_options[:title].present?
      html+=%Q{#{content_tag(:h4, default_options[:title])}} if !default_options[:dropdown]
      html+=%Q{<a href='#' data-toggle="dropdown" class="#{default_options[:class]}">#{default_options[:title]} <span class="caret"></span></a>} if default_options[:dropdown]
    end
    html+=%Q{<div class="btn-group#{default_options[:vertical] ? "-vertical" : ""}">} if !default_options[:dropdown]
    html<<%Q{<ul class="dropdown-menu">} if default_options[:dropdown]
    html<<capture(&block) if block_given?
    if actions.include? :edit
      html<<"<li>" if default_options[:dropdown]
      html<<link_to("Edit", [:edit, item], class: link_class)
      html<<"</li>" if default_options[:dropdown]
    end
    if actions.include? :delete
      html<<"<li>" if default_options[:dropdown]
      html<<link_to("Delete", item, method: :delete, data: {confirm: "Are you sure you wish to delete this #{item.class.name.downcase}?"}, class: link_class)
      html<<"</li>" if default_options[:dropdown]
    end
    if default_options[:dropdown]
      html<<%Q{</ul>} 
    else
      html<<"</div>"
    end
    html<<%Q{</div>}
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
