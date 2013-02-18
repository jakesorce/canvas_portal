class Portal < Sinatra::Application

  def database_setup
    system('echo "development:
         adapter: mysql2
         encoding: utf8
         database: udemodo
         host: localhost 
         port: 3306
         username: root
         password: swordfish
         timeout: 5000" > config/database.yml')
  end

  def bundle
    lock_file = "#{Dirs::UDEMODO}/Gemfile.lock"
    File.delete(lock_file) if File.exists? lock_file
    Tools.one_eight_command('bundle update')
  end

  def swap_files_start
    system("sudo su - root -c 'cat #{Dirs::FILES}/passenger_udemodo.txt > /etc/apache2/httpd.conf'")
    Tools.apache_server('start')
  end
  
  def initial_git_setup
    Tools.one_eight_command('git reset --hard origin/master && git checkout master && git fetch && git rebase origin/master')
  end

  def dcm_courses_jobs
    Tools.one_eight_command('RAILS_ENV=development bundle exec rake db:drop db:create db:migrate import:courses && bundle exec script/delayed_job start')
  end

  def remove_net_pids
    net_pids = "#{Dirs::UDEMODO}/tmp/pids/delayed_job.pid"
    File.open(net_pids).each { |line| system("kill -9 #{line}") } if File.exists? net_pids
  end

  post "/master_canvas_net" do
    branch = 'canvas network master'
    Writer.write_info(branch)
    Writer.write_file(Files::BRANCH_FILE, branch)
    remove_net_pids
    Dir.chdir("#{Dirs::UDEMODO}") do
      database_setup
      initial_git_setup
      bundle
      dcm_courses_jobs
      swap_files_start
    end
  end

  post "/canvasnet_patchset" do
    patchset = params.values.first
    Validation.validate_patchset(patchset)
    Writer.write_info(patchset)
    remove_net_pids
    Dir.chdir("#{Dirs::UDEMODO}") do
      database_setup
      initial_git_setup
      Tools.one_eight_command("git fetch #{Tools::GERRIT_URL}/udemodo refs/changes/#{patchset} && git checkout FETCH_HEAD")
      bundle
      dcm_courses_jobs
      swap_files_start 
    end 
  end
end

