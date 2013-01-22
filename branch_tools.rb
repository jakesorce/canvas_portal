#!/usr/bin/env ruby
require 'optparse'
require '/home/hudson/portal/helpers/branch_tools_helpers.rb'

options = {}
action = ''
optparse = OptionParser.new do |opts|
  opts.on('-c', '--checkout URL', 'updates, does a git checkout, server') do |checkout_url|
    options[:checkout_url] = checkout_url
    action = 'checkout'
  end

  opts.on('-d', '--dump database', 'dumps development database and runs modified load initial data rake task') do |database|
    options[:database] = database
    action = 'dump database'
  end

  opts.on('-b', '--branch name', 'switches to the branch, resets it, runs migrations and assets, and server') do |branch_name|
    options[:branch_name] = branch_name
    options[:branch_name] == 'master' ? action = 'use master' : action = 'use branch'
  end
  
  opts.on('-g', '--generate documentation', 'generates documentation') do |generate|
    options[:generate_documentation] = generate
    action = 'generate documentation'
  end

  opts.on('-p', '--plugin patchset', 'checks out a patchset of a given plugin') do |plugin_checkout_values|
    value_parts = plugin_checkout_values.split('*')
    options[:plugin_patchset] = value_parts[0]
    options[:plugin_for_patchset] = value_parts[1]
    options[:plugin_checkout_command] = value_parts[2]
    action = 'plugin patchset'
  end
  
  opts.on('-l', '--validate localization', 'adds code to development.rb to help check localization') do |localize|
     action = 'localize'
   end
  
  opts.on('-v', '--ruby version change', 'executes code needed to do necessary canvas restart after a version change') do |version|
    options[:ruby_version] = version
    action = 'ruby version change'
  end
  
  opts.on('-m', '--multiple patchset checkout', 'checkout each patchset in order from first to last on top of the master branch') do |patchsets|
    options[:patchsets] = patchsets
    action = 'checkout multiple'
  end

  opts.on('-h', '--help', 'Display this screen') do
    puts opts
    exit
  end
end

optparse.parse!

ENV["HOME"] ||= "/home/hudson/canvas-lms/public" 
ENV["RAILS_ENV"] = 'development'
ENV['CANVAS_LMS_ADMIN_EMAIL']='test'
ENV['CANVAS_LMS_ADMIN_PASSWORD']='password'
ENV['CANVAS_LMS_ACCOUNT_NAME']='QA Testing'
ENV["CANVAS_LMS_STATS_COLLECTION"]='opt_out'

Dir.chdir('/home/hudson/canvas-lms') do
  BTools.pre_setup
  case action
    when 'checkout'
      BTools.checkout(options[:checkout_url])
    when 'checkout multiple'
      BTools.checkout_multiple(options[:patchsets].split(','))
    when 'dump database'
      BTools.reset_database
    when 'use master'
      BTools.canvas_master
    when 'use branch'
      BTools.branch(options[:branch_name])
    when 'generate documentation'
      BTools.documentation
    when 'localize'
      BTools.localize
    when 'ruby version change'
      BTools.change_version(options)
    when 'plugin patchset'
      BTools.plugin_patchset(options[:plugin_for_patchset], options[:plugin_checkout_command])
  end
end
