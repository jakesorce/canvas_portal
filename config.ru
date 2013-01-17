require './portal'
require 'rack/contrib'

use Rack::Deflater
use Rack::StaticCache, :urls => ["/images"], :root => Dir.pwd + '/public'
run Portal.new
