module ApplicationHelper
  def title(t)
    "Shop!" + (t.blank? ? "" : " | #{t}")
  end

  class ActionBarBuilder 
    include ActionView::Helpers::UrlHelper

    def initialize(options={})
      @options=options
      @link_class=(options[:dropdown] ? "" : "btn btn-default")
    end
    def header
      html=%Q{<div class="#{@options[:class]}#{@options[:dropdown] ? ' dropdown' : '' }">}
      if @options[:title].present?
        html<<%Q{#{content_tag(:h4, @options[:title])}} if !@options[:dropdown]
        html<<%Q{<a href='#' data-toggle="dropdown" class="#{@options[:class]}">#{@options[:title]} <span class="caret"></span></a>} if @options[:dropdown]
      end
      html<<%Q{<div class="btn-group#{@options[:vertical] ? "-vertical" : ""}">} if !@options[:dropdown]
      html<<%Q{<ul class="dropdown-menu">} if @options[:dropdown]
      html
    end
    def item(text, url, options={})
      html=""
      html<<"<li>" if @options[:dropdown]
      html<< link_to(text, url, {class: @link_class}.merge(options))
      html<<"</li>" if @options[:dropdown]
      html<<"\n"
      html.html_safe
    end
    def footer
      html=""
      if @options[:dropdown]
        html<<%Q{</ul>} 
      else
        html<<"</div>"
      end
      html<<%Q{</div>}
    end
  end

  def action_bar(item, options={}, &block)
    default_actions=[:edit, :delete]
    default_options={class: "action_bar", title: "Actions", vertical: true, dropdown: false}
    default_options.merge!(options)
    action_buttons=ActionBarBuilder.new(default_options)
    actions=default_actions - options[:except].to_a
    actions=*options[:only] if options[:only]
    html=action_buttons.header
    html<<capture(action_buttons, &block) if block_given?
    if actions.include? :edit
      edit_options={}.merge(default_options[:edit].to_h)
      html<<action_buttons.item("Edit", url_for([:edit, item]), edit_options)
    end
    if actions.include? :delete
      delete_options={method: :delete, data: {confirm: "Are you sure you wish to delete this #{item.class.name.downcase}?"}}.merge(default_options[:delete].to_h)
      html<<action_buttons.item("Delete", url_for(item), delete_options)
    end
    html<<action_buttons.footer
    html.html_safe
  end

  def cost_to_currency(item)
    return if item.nil? or item.currency.nil?
    currency=item.currency
    cost=item.cost / (10.0**currency.decimal_places)
    number_to_currency(cost, unit: currency.symbol, precision: currency.decimal_places)
  end

  def css_id(item)
    "#{item.class.name.parameterize}_#{item.new_record? ? 'new' : item.id }"
  end
end
