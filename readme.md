
    #######################################
    ##      ALPHA SOFTWARE WARNING       ##
    #######################################

# Boucher

*Be the butcher, not the meat.*

Using a Meatfile to describe some conventions of your infrastructure, run the `knife bootstrap` command
on a freshly deployed server. The Meatfile will build the `knife bootstrap` command and allow you to
run through a gateway/jumpserver and also autoconfigure the network settings on said server before running
Chef.

## Prerequisites

Boucher isn't for everyone. It's actually got a pretty narrow target userbase, but for those that may use it,
it could be an invaluable timesaver.

The following assumptions are made:

 * When deploying a server from a template (eg: via VMWare ESXi), the server has a predictable IP/hostname
 * You follow a predictable pattern with naming your servers (eg: app001.prod for a production appserver 1)
 * You already have the server's hostname configured on your DNS server.
 * Different environments (production, staging, etc) use subnets with similar IP addressing (eg: prod: 10.0.0.0/24, staging: 10.0.1.0/24)

## Features

Boucher sports a robust set of features for getting you up and running quickly.

 * support for a gateway/jump box.
 * mapping/aliasing role names
 * mapping/aliasing environment names
 * autoconfiguration of networking based on DNS

## Example Workflow

In our example workflow, we will assume that 

A `Meatfile` is created in your working directory containing rules for translating your configuration.

An example `Meatfile` would be:

    user 'admin'                      # the user that knife uses for bootstrap
    raw_system_address '10.0.0.200'   # the IP of an unconfigured system
    base_domain 'example.com'         # primary domain of your infrastructure

    gateway_suffix '1'                # the final octet of your router/gateway
    nameserver_suffix '2'             # the final octet of your DNS server

    gateway_server 'user@gw.example.com'  # the jumpbox/gateway
    chef_server 'chef.example.com'    # the hostname of your chef server (used by knife bootstrap)

    # map roles:
    map_role :app, 'appserver-ruby19'
    map_role :db, 'postgres-server'
    map_role :search, 'lucene-server'

    # map environments
    map_env :prod, 'production'

    # rule for translating hostname into role/serial/environment
    map_hostname do |hostname, blueprint|
      # EXPERIMENTAL
    end

You could then create a DNS entry for 2 appservers; one for production and one for staging:

 * app001.prod.example.com
 * app002.staging.example.com

Have your chef cookbooks deployed to your chef server and ensure that you have a role called `appserver-ruby19`.
This is the role that will be applied to your server via `knife bootstrap`.

Deploy a machine from your template with the `raw_system_address` and ensure that it's configured to use your
`base_domain` as the search domain in `resolv.conf`.

Run the following command to get started:

    boucher app001.staging

Boucher will then use Capistrano to connect to your chef server and look up the IP of `app001.staging.example.com`.
It will check to see if that machine is currently online via `ping` and if so, prompt you about whether it should
try to run `chef-client`. If the machine is not online, it will attempt to connect to the IP configured as
`raw_system_address` (10.0.0.200) and craft a network configuration based on the looked up IP.

After the machine's networking is configured, it will reboot the machine and wait for it to come back online by
continuously pinging it. This will give you a chance to change the networking configuration in ESX or whatever
other virtualization infrastructure you have.

Once it's been detected as being online again, it will craft a `knife bootstrap` command to be run from the
`chef_server`. The parameters passed to `knife bootstrap` are as follows:

 * username to log in as
 * password (you will be prompted for this)
 * runlist (really, just the role; as in `role[$ROLE]`)
 * environment

Once that is complete, `boucher` will exit.

## Other Features

### Meatfile

contains configuration.
Can be discovered as `./Meatfile`, a `Meatfile` in any directory going up from `.` to `/`, `~/.meatfile`, `~/.boucher`, or `/etc/boucher`.

### configuration rules

    # hostname -- the hostname being passed into function
    # bp -- the blueprint object, fully configured.
    map_hostname do |hostname, bp|
      bp.merge!(Hash[([:role,:serial,:environment].zip hostname.scan(/^(.+?)(\d+)\.(.+?)$/).flatten)])
    end

    # or pass a lambda:
    map_hostname = lambda { ... }

Default roles, environments, serials:

    default_role :app
    default_env :qa
    default_serial ''

Password:

    # store the password in plain text in the Meatfile
    # (NOT RECOMMENDED)
    password ''

prompt for password:

    # display a prompt
    password :prompt

    # custom prompt:
    password :prompt, 'Boucher Password: '
or

    # pass the path to a file containing the password
    # will be `chomp`'d
    password_file '~/.boucher_pass'
