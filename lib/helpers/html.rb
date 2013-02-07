module Sinatra::HtmlHelpers
  def h(str)
    Rack::Utils.escape_html(str)
  end

  def patchset_form(form_id, input_id)
    <<-HTML
      <form id="#{form_id}" method="post" class="form-horizontal">
        <div class="control-group">
          <label class="control-label">Patchset Numbers:</label>
          <div class="controls">
            <input required name="#{input_id}" id="#{input_id}" type="text" placeholder="62/14362/6" />
            <button type="button" class="help_button btn hidden-phone">Help?</button>
          </div>
        </div>
        <div>
          <input id="generate_environment" type="submit" value="Generate Environment" name="submit" class="btn btn-primary" />
        </div>
      </form>  
    HTML
  end

  def multiple_patchset_form
  end

  def check_with_label(checkbox_id, label_text)
    <<-HTML
      <label class="checkbox">
        <input type="checkbox" id="#{checkbox_id}">
        #{label_text}
      </label>
    HTML
  end
end
