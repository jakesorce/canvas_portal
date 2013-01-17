module Sinatra::HtmlHelpers
  def h(str)
    Rack::Utils.escape_html(str)
  end

  def patchset_form(form_id, input_id)
    html = ''
    html << "<form id='#{form_id}' method='post' class='form-horizontal'>"
    html << '<div class="control-group">'
    html << '<label class="control-label">Patchset Numbers:</label>'
    html << '<div class="controls">'
    html << "<input required name='#{input_id}' id='#{input_id}' type='text' placeholder='62/14362/6' />"
    html << '<button type="button" class="help_button btn hidden-phone">Help?</button></div></div>'
    html << '<div><input id="generate_environment" type="submit" value="Generate Environment" name="submit" class="btn btn-primary" /></div>'
    html << '</form>'
    html
  end

  def multiple_patchset_form
  end
end
