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
    File.delete('Gemfile.lock')
    system('bundle update')
  end

  def swap_files_start
    system("sudo su - root -c 'cat /home/hudson/files/passenger_udemodo.txt > /etc/apache2/httpd.conf'")
    system('sudo apachectl start')
  end
  
  def initial_git_setup
    system("#{ONE_EIGHT_SHELL} git reset --hard origin/master && git checkout master && git fetch && git rebase origin/master'")
  end

  def dcm_courses_jobs
    system("#{ONE_EIGHT_SHELL} RAILS_ENV=development bundle exec rake db:drop db:create db:migrate import:courses && bundle exec script/delayed_job start'")
  end

  post "/master_canvas_net" do
    Files.remove_files
    branch = 'canvas network master'
    Writer.write_info(branch)
    Writer.write_file(BRANCH_FILE, branch)
    net_pids = '/home/hudson/udemodo/tmp/pids/delayed_job.pid'
    File.open(net_pids).each { |line| system("kill -9 #{line}") } if File.exists? net_pids
    execution_time = Benchmark.realtime do
      Dir.chdir('/home/hudson/udemodo') do
        database_setup
        initial_git_setup
        bundle
        dcm_courses_jobs
        swap_files_start
      end
    end
    ActionTime.store_action_time('master_canvas_net', execution_time) if Validation.check_error_file
  end

  post "/canvasnet_patchset" do
    Files.remove_files
    patchset = params.keys[0]
    Writer.write_info(patchset)
    Writer.write_file(PATCHSET_FILE, patchset)
    net_pids = '/home/hudson/udemodo/tmp/pids/delayed_job.pid'
    File.open(net_pids).each { |line| system("kill -9 #{line}") } if File.exists? net_pids
    execution_time = Benchmark.realtime do
      database_setup
      initial_git_setup
      system("#{ONE_EIGHT_SHELL} git fetch #{GERRIT_URL}/udemodo refs/changes/#{patchset} && git checkout FETCH_HEAD'")
      bundle
      dcm_courses_jobs
      swap_files_start  
    end
    ActionTime.store_action_time('canvasnet_patchset' execution_time) if Validation.check_error_file
  end
end

