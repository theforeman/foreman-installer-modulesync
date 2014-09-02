require 'puppetlabs_spec_helper/module_spec_helper'
<% (@configs['requires'] || []).each do |r| -%>
require '<%= r %>'
<% end -%>

# Workaround for no method in rspec-puppet to pass undef through :params
class Undef
  def inspect; 'undef'; end
end
<%= "\n" + @configs['extra_code'] if @configs['extra_code'] -%>
