require 'redmine'
require 'date'
require 'active_support'

require File.dirname(__FILE__) + '/lib/issues_controller_patch.rb'

require 'dispatcher'
Dispatcher.to_prepare :redmine_due_date_by_default do
  require_dependency 'issues_controller'
  IssuesController.send(:include, RedmineDueDateByDefault::Patches::IssuesControllerPatch)  
end

Redmine::Plugin.register :redmine_due_date_by_default do
  name 'Redmine Due Date By Default'
  author 'Aaron Addleman'
  description 'Set due date with a custom offset'
  version '0.0.1'
  url 'http://9thport.net/'
  author_url 'http://github.com/9thport'
end
