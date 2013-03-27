module Dirs
  HUDSON = '/home/hudson'
  FILES = File.expand_path("#{HUDSON}/files", File.dirname(__FILE__))
  PORTAL = File.expand_path("#{HUDSON}/portal", File.dirname(__FILE__))
  CONFIG = File.expand_path("#{PORTAL}/config", File.dirname(__FILE__))
  UDEMODO = File.expand_path("#{HUDSON}/udemodo", File.dirname(__FILE__))
  CANVAS = File.expand_path("#{HUDSON}/canvas-lms",File.dirname(__FILE__))
  SINATRA_LOGS = File.expand_path("#{HUDSON}/logs",File.dirname(__FILE__))
end
