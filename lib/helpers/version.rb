module Version
  def global
    `rbenv global`
  end

  def change_version(params)
    #system("rbenv global #{version} && rbenv rehash")
    params.values.first == "1.9.3-p286" ? one_nine_command(Tools.btools_command(params)) : one_eight_command(Tools.btools_command(params))
  end
  module_function :global
  module_function :change_version
end
