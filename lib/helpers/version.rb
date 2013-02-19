module Version
  def global
    `rbenv global`
  end

  def change_version(params)
    version = params.values.first
    system("rbenv global #{version} && rbenv rehash")
    version == "1.9.3-p286" ? Tools.one_nine_command(Tools.btools_command(params)) : Tools.one_eight_command(Tools.btools_command(params))
  end
  module_function :global
  module_function :change_version
end
