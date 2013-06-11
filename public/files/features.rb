#Add this fine to usr/files
Setting.set('enable_page_views', 'db')
Account.default.enable_service(:analytics)
Setting.set('show_feedback_link', 'true')
Setting.set('enable_page_views', 'cassandra')
Account.default.tap do |a|
  a.settings[:enable_scheduler] = true
  a.settings[:show_scheduler] = true
  a.save!
end
PluginSetting.new(:name => "kaltura", :settings => {"rtmp_domain"=>"rtmp.instructuremedia.com", "kcw_ui_conf"=>"1727883", "domain"=>"www.instructuremedia.com", "user_secret_key"=>"54122449a76ae10409adcefa3148f4b7", "secret_key"=>"ed7eae22d60b82e0b44fb95089ddb228", "player_ui_conf"=>"1727899", "upload_ui_conf"=>"1103", "partner_id"=>"100", "subpartner_id"=>"10000", "resource_domain"=>"www.instructuremedia.com"}).save
