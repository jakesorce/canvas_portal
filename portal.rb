require 'rubygems'
require 'sinatra'
require 'sinatra/minify'
require 'active_record'
require 'benchmark'
require 'active_support'
require 'active_support/core_ext/time/zones'
require 'active_support/time_with_zone'
require 'mail'
require 'yaml'
require 'haml'
require File.expand_path(File.dirname(__FILE__) + '/lib/helpers/html')

ROUTES = %w[branch master_canvas_net canvasnet_patchset checkout checkout_multiple plugin_patchset dcm_initial_data change_version]
PORTAL_CONFIG = YAML.load_file(File.expand_path(File.dirname(__FILE__) + '/config/portal.yml'))
Mail.defaults do
  delivery_method :smtp, { :address   => PORTAL_CONFIG['sendgrid']['address'],
                           :port      => PORTAL_CONFIG['sendgrid']['port'],
                           :domain    => PORTAL_CONFIG['sendgrid']['domain'],
                           :user_name => PORTAL_CONFIG['sendgrid']['username'],
                           :password  => PORTAL_CONFIG['sendgrid']['password'],
                           :authentication => PORTAL_CONFIG['sendgrid']['authentication'],
                           :enable_starttls_auto => PORTAL_CONFIG['sendgrid']['starttls_auto'] }
end

class Portal < Sinatra::Application
  register Sinatra::Minify
  helpers Sinatra::HtmlHelpers
 
  set :public_folder, 'public', File.dirname(__FILE__)
  set :root, 'app', File.dirname(__FILE__) 
  set :js_path, 'public/javascripts'
  set :js_url, '/javascripts'

  require_relative 'lib/init'
  require_relative 'app/routes/init'
  
  def route
    request.path_info.split('/')[1]
  end
  
  def correct_route?
    ROUTES.include? route
  end

  before do
    @start_time = Time.now.to_f
    if correct_route?
      Files.remove_files
      Writer.write_file(Files::GENERATING_FILE, 'generating')
    end
  end

  after do
    Files.remove_file(Files::GENERATING_FILE) if File.exists? Files::GENERATING_FILE
    ActionTime.store_action_time(route, (Time.now.to_f - @start_time)) if correct_route? && Validation.check_error_file
    if correct_route? && Validation.check_error_file == false 
      status 400
      response.write(File.open(Files::ERROR_FILE).gets)
    end
  end
end
