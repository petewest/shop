module ApplicationHelper
  def title(t)
    "Shop!" + (t.blank? ? "" : " | #{t}")
  end

  class ActionBarBuilder 
    include ActionView::Helpers::UrlHelper

    def initialize(options={})
      @options=options
      @item_options={class: (options[:dropdown] ? "" : "btn btn-default")}
      @item_options=@item_options.merge(options[:item]) if options[:item]
    end
    def header
      html=%Q{<div class="#{@options[:class]}#{@options[:dropdown] ? ' dropdown' : '' }">}
      if @options[:title].present?
        html<<%Q{#{content_tag(:h4, @options[:title])}} if !@options[:dropdown]
        html<<%Q{<a href='#' data-toggle="dropdown">#{@options[:title]} <span class="caret"></span></a>} if @options[:dropdown]
      end
      html<<%Q{<div class="btn-group#{@options[:vertical] ? "-vertical" : ""}">} if !@options[:dropdown]
      html<<%Q{<ul class="dropdown-menu">} if @options[:dropdown]
      html
    end
    def item(text, url, options={})
      html=""
      html<<"<li>" if @options[:dropdown]
      html<< link_to(text, url, @item_options.merge(options))
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

  def action_bar(item=nil, options={}, &block)
    #If item is a hash then it's really the options, so re-jigg
    options, item=item.merge(only: nil), nil if item.is_a?(Hash)
    #find the default translations for actions:
    #have to use array lookup instead of hash as hash lookup ignores variable interpolation
    edit_label, delete_label, delete_confirm=t([:edit, :delete, :delete_confirm], scope: 'actions', item: item.class.name.titleize)
    default_actions=[:edit, :delete]
    default_options={class: "action_bar", title: "Actions", vertical: true, dropdown: false}
    default_options[:item]={data: {modal_target: '#modal'}} if options[:remote] or params[:modal]
    default_options.merge!(options)
    edit_options=default_options[:edit].to_h
    delete_options={method: :delete, data: {confirm: delete_confirm}}.merge(default_options[:delete].to_h)
    #use shortcut remote: true to specify default actions should be ajax
    delete_options[:remote]=true if options[:remote]
    action_buttons=ActionBarBuilder.new(default_options)
    except=*options[:except]
    actions=default_actions - except
    actions=*options[:only] if options.has_key?(:only)
    html=action_buttons.header
    html<<capture(action_buttons, &block) if block_given?
    # if we've given a namespace in options, use it
    item=[options[:namespace], item] if options[:namespace]
    if item and actions.include?(:edit)
      html<<action_buttons.item(t('.actions.edit', default: edit_label), url_for([:edit, item].flatten), edit_options)
    end
    if item and actions.include?(:delete)
      html<<action_buttons.item(t('.actions.delete', default: delete_label), url_for(item), delete_options)
    end
    html<<action_buttons.footer
    html.html_safe
  end

  def filter_bar(filters)
    action_bar(title: "Filters", dropdown: true, class: "filter_menu") do |a|
      filters.map do |filter,value|
        construct_filter(a, filter, value)
      end.join.html_safe
    end
  end

  def construct_filter(builder, filter, value, use_value_as_title=false)
    text=(use_value_as_title ? value : filter)
    text=text.to_s.titleize
    #if it's an array of options
    if value.is_a?(Array)
      #Allow the user to activate each one
      text=%Q{<li class="dropdown-header">#{text}</li>}
      text+=value.map{ |i| construct_filter(builder, filter, i, true) }.join
    else
      # Find out if the filter is active
      if params[filter]==value.to_s
        #If it is, we'll tick it
        text+=%Q{ <span class="glyphicon glyphicon-ok"></span>}
        #and the new url will exclude it
        url=url_for(params.except(filter))
      else
        #If not we'll set it
        url=url_for(params.merge(filter => value))
      end
      builder.item(text.html_safe, url)
    end
  end

  def cost_to_currency(item)
    return if item.nil? or item.currency.nil?
    to_currency(item.cost, item.currency)
  end

  def to_currency(value, currency)
    cost=value / (10.0**currency.decimal_places)
    number_to_currency(cost, unit: currency.symbol, precision: currency.decimal_places)
  end

  def css_id(item)
    "#{item.class.name.parameterize}_#{item.new_record? ? 'new' : item.id }"
  end

  def add_fields_for_button(form, collection, options={})
    title=(options[:title] || 'Add')
    css_class=(options[:class] || "btn btn-default")
    #create a new object in the collection
    new_object=form.object.reflections[collection].build_association(nil)
    #Find the partial name from options, or from the object
    partial=(options[:partial] || new_object.to_partial_path + '_fields')
    #grab the html to create a new version of this collection object
    form_html=form.fields_for(collection, new_object, child_index: 'dummy_id'){ |f| render partial, f: f }
    html=link_to title, '#', class: css_class, data: { fields_for_html: form_html.to_json, fields_for_collection: collection.to_s }
  end
end
