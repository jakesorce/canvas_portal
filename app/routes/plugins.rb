class Portal < Sinatra::Application
 
  def checkout_plugin(url)
    halt if not Validation.validate_gerrit_url(url)
    plugin_checkout_values = []
    Writer.write_info('plugin patchset checkout')
    url_parts = url.split(' ')
    plugin = url_parts[2].split('/')[3]
    if not Tools::GERRIT_FORMATTED_PLUGINS.include?(plugin)
      status 400
      response.write("plugin is not in the list of supported plugins, click the '?' button to see what plugins are supported and try again")
    else
      plugin_patchset = url_parts[3].split('changes')[1].gsub!(/^[\/]/,"")
      Writer.write_file(Files::PATCHSET_FILE, plugin_patchset)
      Writer.write_file(Files::PLUGIN_FILE, " - this is a plugin patchset for #{plugin}")
      Tools.btools_command(params)
    end
  end
  
  get "/plugins_list" do
    response.write(Tools::SUPPORTED_PLUGINS)
  end

  post "/plugin_patchset" do
    values = params.values.first.split('*')
    url = values.last
    checkout_plugin(url)
  end

  post "/plugin_magic" do
    url = params[:plugin_patchset]
    half if not Validation.validate_gerrit_url(params[:plugin_patchset])
    checkout_plugin(url)
  end

  post "/checkout_multiple_plugins" do
    plugins = params.values.first
    file_formatted_plugins = []
    plugins.split('*').each do |plugin| 
      halt 400 if not Validation.validate_plugin(plugin)
      file_formatted_plugins << "#{plugin.split('changes/').last.split(' ').first}"
    end

    Writer.write_info('multiple plugins checkout')
    Writer.write_file(Files::MULTIPLE_FILE, file_formatted_plugins.join('*'))
    Tools.btools_command(params)
  end
end
