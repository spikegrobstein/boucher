module Boucher
  class CLI

    attr_accessor :hostname
    attr_accessor :meatfile

    def initialize(args)
      @hostname = args.first
      @meatfile = Meatfile::hunt_for_meat
      @config = Config.new(@meatfile)

      raise "Config not valid" unless @config.valid?

      @blueprint = Blueprint.new(@hostname, 'role', @config)
    end

    # FIXME a lot of this shit should be in Boucher::Base or something
    # not in the CLI portion. sheesh.
    def run!
      @cap = Capistrano.new(@blueprint)

      #@cap.run_recipe
    end


  end
end
