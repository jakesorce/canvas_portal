#!/usr/bin/env ruby
require 'optparse'
require File.expand_path(File.dirname(__FILE__) + '/../portal/lib/helpers/branch_tools_helpers')
FILES_BASE = File.expand_path(File.dirname(__FILE__) + '/../files')

def write_file(file_path, contents, write_flag = 'a+')
    File.open(file_path, write_flag) { |file| file.write(contents) }
end

options = {}
action = ''
optparse = OptionParser.new do |opts|
  opts.on('-d', '--default action', 'pass it a , delimited string of params: example "branch, master, localization, docs"') do |params|
    values = params.split(',')
    options[:action] = values[0]
    options[:value] = values[1]
    write_file("#{FILES_BASE}/documentation.txt", 'docs') if values.include? 'docs'
    write_file("#{FILES_BASE}/localization.txt", 'localize') if values.include? 'localization'
  end

  opts.on('-h', '--help', 'Display this screen') do
    puts opts
    exit
  end
end

optparse.parse!

ENV["HOME"] ||= "/home/hudson/canvas-lms/public" 
ENV["RAILS_ENV"] = 'production'
ENV['CANVAS_LMS_ADMIN_EMAIL']='test'
ENV['CANVAS_LMS_ADMIN_PASSWORD']='password'
ENV['CANVAS_LMS_ACCOUNT_NAME']='QA Testing'
ENV["CANVAS_LMS_STATS_COLLECTION"]='opt_out'

Dir.chdir('/home/hudson/canvas-lms') do
  log_path = 'log'
  Dir.foreach(log_path) {|f| fn = File.join(log_path, f); File.delete(fn) if f != '.' && f != '..'}
  BTools.pre_setup
  case options[:action]
    when 'documentation'
      BTools.documentation
    when 'portal_form_patchset'
      BTools.checkout(options[:value])
    when 'patchsets'
      BTools.checkout_multiple(options[:value].split('*'))
    when 'reset_database'
      BTools.reset_database
    when 'branch'
      value = options[:value]
      value == 'master' ? BTools.canvas_master : BTools.branch(value) 
    when 'version'
      BTools.change_version(Git.current_branch)
    when 'plugin_patchset'
      BTools.plugin_patchset(options[:value])
  end
end
