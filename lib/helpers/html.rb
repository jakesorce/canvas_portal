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
            <label id="cherry_pick_label" class="checkbox pull-right">
              <input id="cherry_pick_option" name="cherry-pick" type="checkbox"> cherry-pick
            </label>
          </div>
        </div>
        <div>
          <input id="generate_environment" type="submit" value="Generate Environment" name="submit" class="btn btn-primary" />
        </div>
      </form>  
    HTML
  end

  def check_with_label(checkbox_id, label_text)
    <<-HTML
      <label class="checkbox">
        <input type="checkbox" id="#{checkbox_id}">
        #{label_text}
      </label>
    HTML
  end

  def list_item(value)
    <<-HTML
      <li>#{value}</li>
    HTML
  end

  def hover_info
    info_file = Files::INFO_FILE
    error_file = Files::ERROR_FILE
    error_text = "error occurred on last action, try again"
    no_action_text = "no portal action has taken place"
    patchset_text = Files.first_line(Files::PATCHSET_FILE)
    doc_text = 'documentation flag' if File.exists? Files::DOCUMENTATION_FILE
    localization_text = 'localization flag' if File.exists? Files::LOCALIZATION_FILE
    action_flags = []
    action_flags << doc_text << localization_text
    action_flags.compact!
    patchset_html = "<div class='pad-bottom'><h5>Current Patchset:</h5><div id='patchset_info'>#{patchset_text}</div></div>" if patchset_text
    action_flags_html = "<div class='pad-bottom'><h5>Action Flags Used On Last Code Changing Action:</h5><div id='action_flags_info'>#{action_flags.join("<br />")}</div></div>" if not action_flags.empty?
    dt_last_action = last_action = no_action_text
    if File.exists? info_file
      dt_last_action = Files.first_line(info_file)
      last_action = File.readlines(info_file).last
    elsif File.exists? error_file 
      dt_last_action = last_action = error_text
    end
    <<-HTML
      <div id="canvas_state_info" class="invisible">
        <div id="hover_info_popup" class="center">
          <div class="pad-bottom">
            <h5>Current Branch:</h5>
            <div id="branch_info">#{Files.branch_file}</div>
          </div>
          #{patchset_html}
          <div class="pad-bottom">
            <h5>Date and Time of Last Action:</h5>
            <div id="action_info">#{dt_last_action}</div>
          </div>
          <div class="pad-bottom">
            <h5>Last Action Performed:</h5>
            <div id="last_action">#{last_action}</div>
          </div>
          #{action_flags_html}
          <div class="pad-bottom">
            <h5>Canvas-LMS Ruby Version:</h5>
            <div>#{Version.global}</div>
          </div>
          <div class="pad-bottom">
            <h5>Canvas Defaults:</h5>
            <div>Username: test</div>
            <div>Password: password</div>
          </div>
        </div>
      </div>  
    HTML
  end
end
