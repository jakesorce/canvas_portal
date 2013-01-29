class Portal < Sinatra::Application
  post "/checkout" do
    Files.remove_files
    execution_time = Benchmark.realtime do
      patchset = params.keys[0]
      exit! 1 if Validation.validate_patchset(patchset) == nil
      Writer.write_info('patchset checkout')
      Writer.write_file(PATCHSET_FILE, patchset)
      checkout_command = "git fetch #{GERRIT_URL}/canvas-lms.git refs/changes/#{patchset} && git checkout FETCH_HEAD"
      system("ruby /home/hudson/canvas-lms/branch_tools.rb -c '#{checkout_command}'")
    end
    ActionTime.store_action_time('checkout', execution_time) if Validation.check_error_file
  end

  post "/checkout_multiple" do
    Files.remove_files
    execution_time = Benchmark.realtime do
      patchsets = params.keys[0]
      patchsets.split('*').each do |patchset| 
        exit! 1 if Validation.validate_patchset(patchset)
      end
      Writer.write_info('multiple patchset checkout')
      Writer.write_file(MULTIPLE_FILE, patchsets)
      system("ruby /home/hudson/canvas-lms/branch_tools.rb -m '#{patchsets}'")
    end
    ActionTime.store_action_time('checkout_multiple', execution_time) if Validation.check_error_file
  end
end
