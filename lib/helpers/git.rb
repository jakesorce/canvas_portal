module Git
  def all_branches
    `git branch -r`
  end

  def current_branch
    Dir.chdir("#{Dirs::HUDSON}/canvas-lms") { `git rev-parse --abbrev-ref HEAD` }
  end
  module_function :current_branch
  module_function :all_branches
end
