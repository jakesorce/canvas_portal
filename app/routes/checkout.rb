class Portal < Sinatra::Application
  def flags?(params)
    update_flags(params[:docs], params[:localization])
  end

  def parse_patchset(patchset)
    patchset.split('changes/').last.split(' ').first
  end
  
  def format_patchsets(patchsets)
    p = patchsets.split('*')
    p.map! do |patchset| 
      patchset.strip! 
      patchset.length > 13 ? parse_patchset(patchset) : patchset
    end
    p.join('*')
  end

  post "/checkout" do
    patchset = params.values.first.length > 13 ? parse_patcshet(params.values.first) : params.values.first.strip!
    params['portal_form_patchset'] = patchset
    halt 400 if not Validation.validate_patchset(patchset)
    update_fields({portal_action: 'patchset checkout', patchset: patchset})
    flags?(params)
    Tools.btools_command(params)
  end

  post "/checkout_multiple" do
    patchsets = format_patchsets(params.values.first)
    patchsets.split('*').each { |patchset| halt 400 if not Validation.validate_patchset(patchset) }
    update_fields({portal_action: 'multiple patchset checkout', multiple: patchsets})
    flags?(params)
    params['patchsets'] = patchsets 
    Tools.btools_command(params)
  end
 
  post "/patchset_and_plugin" do
    params[:patchset] = parse_patchset(params[:patchset]) if params[:patchset].length > 13 
    params[:patchset].strip!
    halt 400 if not Validation.validate_patchset(params[:patchset])
    halt 400 if not Validation.validate_plugin(params[:plugin])
    plugin_patchset = params[:plugin]
    patchset_id = plugin_patchset.split('changes/').last.split(' ').first
    update_fields({portal_action: 'checkout patchset + plugin patchset', patchset: params[:patchset], plugin: plugin_patchset, multiple: patchset_id})
    flags?(params)
    Tools.btools_command(params)
  end
end
