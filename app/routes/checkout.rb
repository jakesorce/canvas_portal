class Portal < Sinatra::Application
  post "/checkout" do
    patchset = params.values.first
    halt 400 if not Validation.validate_patchset(patchset)
    update_fields({portal_action: 'patchset checkout', patchset: patchset})
    update_flags(params[:docs], params[:localization])
    Tools.btools_command(params)
  end

  post "/checkout_multiple" do
    patchsets = params.values.first
    patchsets.split('*').each { |patchset| halt 400 if not Validation.validate_patchset(patchset) }
    update_fields({portal_action: 'multiple patchset checkout', multiple: patchsets})
    update_flags(params[:docs], params[:localization])
    Tools.btools_command(params)
  end
end
