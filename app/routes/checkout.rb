class Portal < Sinatra::Application
  post "/checkout" do
    patchset = params.values.first
    Validation.validate_patchset(patchset)
    Writer.write_info('patchset checkout')
    Writer.write_file(Files::PATCHSET_FILE, patchset)
    Tools.btools_command(params)
  end

  post "/checkout_multiple" do
    patchsets = params.values.first
    patchsets.split('*').each { |patchset| Validation.validate_patchset(patchset) }
    Writer.write_info('multiple patchset checkout')
    Writer.write_file(Files::MULTIPLE_FILE, patchsets)
    Tools.btools_command(params)
  end
end
