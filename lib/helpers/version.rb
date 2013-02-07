module Version
  def global
    `rbenv global`
  end

  def change_version(version)
    system("rbenv global #{version} && rbenv rehash")
    system("bash -lc 'rbenv shell #{version} && rbenv rehash && ruby /home/hudson/canvas-lms/branch_tools.rb -v #{version}'")
  end
  module_function :global
  module_function :change_version
end
