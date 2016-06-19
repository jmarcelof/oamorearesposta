class DatepickerInput < SimpleForm::Inputs::Base
  def input
    @value_input = "#{input_options[:class]}[#{attribute_name}]"
    template.content_tag(:div, class: 'input-group date form_datetime') do
      template.concat @builder.text_field(attribute_name, input_html_options)
      template.concat span_table
   end
 end

 def input_html_options
   super.merge({class: 'form-control', name: "#{@value_input}"})
 end

  def span_table
    template.content_tag(:span, class: 'input-group-addon') do
      template.concat icon_table
    end
  end

  def icon_table
    "<i class='glyphicon glyphicon-th'></i>".html_safe
  end
end