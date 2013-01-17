class Portal < Sinatra::Application
  get "/plugins_list" do
    response.write(SUPPORTED_PLUGINS)
  end

  post "/plugin_patchset" do
    Files.remove_files
    execution_time = Benchmark.realtime do
      Writer.write_info('plugin patchset checkout')
      plugin_checkout_values = []
      url = params.values[0]
      url_parts = url.split(' ')
      plugin = url_parts[2].split('/')[3]
      if !GERRIT_FORMATTED_PLUGINS.include?(plugin)
        status 400
        response.write("plugin is not in the list of supported plugins, click the '?' button to see what plugins are supported and try again")
      else
        plugin_patchset = url_parts[3].split('changes')[1]
        Writer.write_file(PATCHSET_FILE, plugin_patchset)
        Writer.write_file(PLUGIN_FILE, " - this is a plugin patchset for #{plugin}")
        checkout_command = "#{GERRIT_URL}/#{plugin}.git refs/changes#{plugin_patchset} && git checkout FETCH_HEAD"
        plugin_checkout_values << plugin_patchset + "*"
        plugin_checkout_values << plugin + "*"
        plugin_checkout_values << checkout_command
        system("ruby /home/hudson/canvas-lms/branch_tools.rb -p '#{plugin_checkout_values}'")
      end
    end
    ActionTime.store_action_time('plugin_patchset', execution_time) if Validation.check_error_file
  end
end
