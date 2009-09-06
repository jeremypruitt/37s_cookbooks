
package "haproxy" do
  action :install
end

directory "/etc/haproxy" do
  action :create
  owner "root"
  group "root"
  mode 0755
end

directory "/var/log/haproxy" do
  action :create
  owner node[:haproxy][:user]
  group node[:haproxy][:user]
  mode 0750
end

directory "/var/run/haproxy" do
  action :create
  owner node[:haproxy][:user]
  group node[:haproxy][:user]
  mode 0750
end

remote_file "/etc/sysctl.d/20-ip-nonlocal-bind.conf" do
  source "20-ip-nonlocal-bind.conf"
  owner "root"
  group "root"
  mode 0644
end

node[:haproxy][:instances].each do |instance|
  instance[:listeners].each_with_index do |listener, idx|
    [ :options, :errorfiles, :backends ].each do |key|
      instance[:listeners][idx][key] = [] unless listener.has_key?(key)
    end
  end

  template "/etc/init.d/haproxy_#{instance[:name]}" do
    source "haproxy.init.erb"
    variables(:instance => instance)
    owner "root"
    group "root"
    mode 0755
  end
  
  service "haproxy_#{instance[:name]}" do
    pattern "haproxy.*#{instance[:name]}"
    supports [ :start, :stop, :restart, :reload ]
    action [ :enable ]
  end

  template "/etc/haproxy/#{instance[:name]}.cfg" do
    source "haproxy.cfg.erb"
    variables(:instance => instance)
    owner node[:haproxy][:user]
    group node[:haproxy][:group]
    mode 0640
    notifies :reload, resources(:service => "haproxy_#{instance[:name]}")
  end
end
