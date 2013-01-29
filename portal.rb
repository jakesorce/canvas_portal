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
require '/home/hudson/portal/helpers/html'

ONE_EIGHT_SHELL = "bash -lc 'rbenv shell ree-1.8.7-2011.03 && rbenv rehash &&"
ONE_NINE_SHELL = "bash -lc 'rbenv shell 1.9.3-p286 && rbenv rehash &&"
BRANCH_FILE = "/home/hudson/files/branch.txt"
PATCHSET_FILE = "/home/hudson/files/patchset.txt"
ERROR_FILE = "/home/hudson/files/error.txt"
PLUGIN_FILE = "/home/hudson/files/plugin.txt"
INFO_FILE = "/home/hudson/files/portal_info.txt"
MULTIPLE_FILE = "/home/hudson/files/multiple.txt"
GENERATION_FILE = "/home/hudson/files/generation.txt"
GERRIT_URL = "ssh://hudson@10.86.151.193/home/gerrit" 
SUPPORTED_PLUGINS = "Analytics,QTI Migration Tool,Banner Grade Export Plugin,Canvas Zendesk Plugin,Custom Reports,Demo Site,IMS ES Importer Plugin,Instructure Misc Plugin,Migration Tool,Multiple Root Accounts,Phone Home Plugin, Canvasnet Registration"
GERRIT_FORMATTED_PLUGINS = ['canvalytics', 'QTIMigrationTool', 'banner_grade_export_plugin', 'canvas_zendesk_plugin', 'custom_reports', 'demo_site', 'ims_es_importer_plugin', 'instructure_misc_plugin', 'canvasnet_registration', 'migration_tool', 'multiple_root_accounts', 'phone_home_plugin']
ROUTES = %w[branch master_canvas_net canvasnet_patchset checkout checkout_multiple documentation localization plugin_patchset dcm_initial_data apache_server change_version]
EMAIL = YAML.load_file('config/email.yml')
Mail.defaults do
  delivery_method :smtp, { :address   => "smtp.sendgrid.net",
                           :port      => 587,
                           :domain    => "instructure.com",
                           :user_name => EMAIL['username'],
                           :password  => EMAIL['password'],
                           :authentication => 'plain',
                           :enable_starttls_auto => true }
end

class Portal < Sinatra::Application
  register Sinatra::Minify
  helpers Sinatra::HtmlHelpers
   
  set :js_path, 'public/javascripts'
  set :js_url, '/javascripts'

  before do
    Writer.write_file(GENERATION_FILE, 'generating') if ROUTES.include? request.path_info.split('/')[1]
  end

  after do
    File.delete(GENERATION_FILE) if File.exists? GENERATION_FILE if ROUTES.include? request.path_info.split('/')[1]
    unless Validation.check_error_file
      status 400
      response.write(File.open(ERROR_FILE).gets)
    end 
  end
end

require_relative 'routes/init'
require_relative 'helpers/init'
