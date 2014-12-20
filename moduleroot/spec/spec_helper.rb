# This file is managed centrally by modulesync
#   https://github.com/theforeman/foreman-installer-modulesync

require 'puppetlabs_spec_helper/module_spec_helper'
<% (@configs['requires'] || []).each do |r| -%>
require '<%= r %>'
<% end -%>

require 'rspec-puppet-facts'
include RspecPuppetFacts

# Workaround for no method in rspec-puppet to pass undef through :params
class Undef
  def inspect; 'undef'; end
end
<%= "\n" + @configs['extra_code'] if @configs['extra_code'] -%>
