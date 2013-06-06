require File.expand_path(File.dirname(__FILE__) + '/portal')
require 'rack/contrib'

use Rack::Deflater
use Rack::StaticCache, :urls => ["/images"], :root => Dir.pwd + '/public'
use ActiveRecord::ConnectionAdapters::ConnectionManagement
run Portal.new
