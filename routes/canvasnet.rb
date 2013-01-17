class Portal < Sinatra::Application
  post "/master_canvas_net" do
    Files.remove_files
    branch = 'canvas network master'
    Writer.write_info(branch)
    Writer.write_file(BRANCH_FILE, branch)
    net_pids = '/home/hudson/udemodo/tmp/pids/delayed_job.pid'
    File.open(net_pids).each { |line| system("kill -9 #{line}") } if File.exists? net_pids
    execution_time = Benchmark.realtime do
      Dir.chdir('/home/hudson/udemodo') do
        system('echo "development:
          adapter: mysql2
          encoding: utf8
          database: udemodo
          host: localhost
          port: 3306
          username: root
          password: swordfish
          timeout: 5000" > config/database.yml')
        system("#{ONE_EIGHT_SHELL} bundle update && RAILS_ENV=development bundle exec rake db:drop db:create db:migrate import:courses && bundle exec script/delayed_job start'")
        system("sudo su - root -c 'cat /home/hudson/files/passenger_udemodo.txt > /etc/apache2/httpd.conf'")
        system('sudo apachectl start')
      end
    end
    ActionTime.store_action_time('master_canvas_net', execution_time) if Validation.check_error_file
  end
end

