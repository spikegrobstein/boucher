module Souce
  class Blueprint < Hash

    def initialize(hostname, role, config)
      parse_hostname(hostname)

      self[:role] = role || config.role_for(self[:role])
      self[:environment] = config.env_for(self[:environment])

      self[:gateway] = config.gateway_server
      self[:domain] = config.base_domain
      self[:system_address] = config.raw_system_address
      self[:gateway_suffix] = config.gateway_suffix
      self[:nameserver_suffix] = config.nameserver_suffix
      self[:user] = config.user
      self[:chef_server] = config.chef_server
    end

    def parse_hostname(hostname)
      self[:hostname] = hostname
      merge!(Hash[([:role,:serial,:environment].zip hostname.scan(/^(.+?)(\d+)\.(.+?)$/).flatten)])
    end
    private :parse_hostname

  end
end
