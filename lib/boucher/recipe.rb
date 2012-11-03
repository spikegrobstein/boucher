task :configure_node, :roles => :raw_node do
  script = File.open( File.join(File.dirname(__FILE__), 'setup.sh'), 'r').read

  put script, "/tmp/setup.sh", :mode => 0755
  run "#{sudo} /tmp/setup.sh #{hostname}"
end

task :bootstrap, :roles => :chef_server do
  run "knife bootstrap #{hostname} -x #{user} -P #{password} -N #{hostname} -r 'role[#{chef_role}]' --sudo -E #{chef_env} --no-host-key-verify"
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
