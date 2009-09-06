directory "/u/apps" do
  owner "app"
  group "app"
  mode 0755
  recursive true
end

if node[:active_applications]

  node[:active_applications].each do |app, conf|
    
    if node[:applications][app][:gems]
      node[:applications][app][:gems].each do |g|
        if g.is_a? Array
          gem_package g.first do
            version g.last
          end
        else
          gem_package g
        end
      end
    end
    
    if node[:applications][app][:packages]
      node[:applications][app][:packages].each do |package_name|
        package package_name
      end      
    end
    
    if node[:applications][app][:symlinks]
      node[:applications][app][:symlinks].each do |target, source|
        link target do
          to source
        end
      end      
    end
  end
else
  Chef::Log.info "Add an :active_applications attribute to configure this node's apps"
end