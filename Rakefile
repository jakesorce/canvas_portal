require './portal'
require 'sinatra/activerecord/rake'

desc "Builds the minified CSS and JS assets."
task :minify do
  require './portal.rb'   # <= change this
  puts "Building..."

  files = Sinatra::Minify::Package.build(Portal)  # <= change this
  files.each { |f| puts " * #{File.basename f}" }
  puts "Construction complete!"
end
