#!/usr/bin/env ruby
require 'optparse'
require '/home/hudson/portal/lib/helpers/branch_tools_helpers.rb'

options = {}
action = ''
optparse = OptionParser.new do |opts|
  opts.on('-d', '--default action', 'pass it a , delimited string of params: example "branch, master, true, true"') do |params|
    values = params.split(',')
    options[:action] = values[0]
    options[:value] = values[1]
    options[:docs] = true if values.include?('doc')
    options[:localization] = true if values.include?('localization')
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
  case options[:action]
    when 'portal_form_patchset'
      BTools.checkout(options[:value])
    when 'patchsets'
      BTools.checkout_multiple(options[:value].split('*'))
    when 'reset_database'
      BTools.reset_database
    when 'branch'
      value = options[:value]
      value == 'master' ? BTools.canvas_master : BTools.branch(value) 
    when 'docs'
      BTools.documentation
    when 'localization'
      BTools.localize
    when 'change_version'
      BTools.change_version(Git.current_branch)
    when 'plugin patchset'
      value_parts = options[:value].split('*')
      BTools.plugin_patchset(value_parts[1], value_parts[2])
  end
end
