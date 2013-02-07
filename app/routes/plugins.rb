class Portal < Sinatra::Application
  get "/plugins_list" do
    response.write(Tools::SUPPORTED_PLUGINS)
  end

  post "/plugin_patchset" do
    url = params.values.first
    Validation.validate_gerrit_url(url)
    plugin_checkout_values = []
    Writer.write_info('plugin patchset checkout')
    url_parts = url.split(' ')
    plugin = url_parts[2].split('/')[3]
    if not Tools::GERRIT_FORMATTED_PLUGINS.include?(plugin)
      status 400
      response.write("plugin is not in the list of supported plugins, click the '?' button to see what plugins are supported and try again")
    else
      plugin_patchset = url_parts[3].split('changes')[1]
      Writer.write_file(Files::PATCHSET_FILE, plugin_patchset)
      Writer.write_file(Files::PLUGIN_FILE, " - this is a plugin patchset for #{plugin}")
      checkout_command = "#{Tools::GERRIT_URL}/#{plugin} refs/changes#{plugin_patchset} && git checkout FETCH_HEAD"
      plugin_checkout_values << plugin_patchset + "*"
      plugin_checkout_values << plugin + "*"
      plugin_checkout_values << checkout_command
      system("ruby /home/hudson/canvas-lms/branch_tools.rb -p '#{plugin_checkout_values.join}'")
    end
  end
end
