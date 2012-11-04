task :configure_node, :roles => :raw_node do
  script = File.open( File.join(File.dirname(__FILE__), 'setup.sh'), 'r').read

  put script, "/tmp/setup.sh", :mode => 0755
  run "#{sudo} /tmp/setup.sh #{node_hostname}"
end

task :bootstrap, :roles => :chef_server do
  run "knife bootstrap #{hostname} -x #{user} -P #{password} -N #{node_hostname} -r 'role[#{node_role}]' --sudo -E #{node_env} --no-host-key-verify"
end

task :wait_for_node_to_come_online, :roles => :chef_server do
  max_tries = 20

  begin
    ping_node
  rescue
    print "."
    $stdout.flush
    max_tries -= 1

    retry if max_tries > 0
  end
end

# upload the cookbooks
task :upload_cookbooks, :roles => :node do
  dest_path = '/tmp/boucher_cookbooks'

  # first, try to delete the old cookbooks
  run "rm -rf #{ dest_path } || true"

  upload fetch(:cookbook_path), dest_path
end

# create solo.rb and run chef-solo
task :run_chef_solo, :roles => :node do
  run "echo 'cookbook_path \"/tmp/boucher_cookbooks\"' > /tmp/boucher_cookbooks/solo.rb"
  run "#{ sudo } chef-solo -o 'roles::#{ node_role }' -c /tmp/boucher_cookbooks/solo.rb"
end


