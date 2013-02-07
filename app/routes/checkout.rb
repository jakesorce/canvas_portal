class Portal < Sinatra::Application
  post "/checkout" do
    patchset = params.values.first
    Validation.validate_patchset(patchset)
    Writer.write_info('patchset checkout')
    Writer.write_file(Files::PATCHSET_FILE, patchset)
    checkout_command = "git fetch #{Tools::GERRIT_URL}/canvas-lms.git refs/changes/#{patchset} && git checkout FETCH_HEAD"
    system("ruby /home/hudson/canvas-lms/branch_tools.rb -c '#{checkout_command}'")
  end

  post "/checkout_multiple" do
    patchsets = params.values.first
    patchsets.split('*').each { |patchset| Validation.validate_patchset(patchset) }
    Writer.write_info('multiple patchset checkout')
    Writer.write_file(Files::MULTIPLE_FILE, patchsets)
    system("ruby /home/hudson/canvas-lms/branch_tools.rb -m '#{patchsets}'")
  end
end
