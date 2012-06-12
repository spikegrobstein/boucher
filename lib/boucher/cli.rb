module Boucher
  class CLI

    # auxiliary meatfile paths
    MEAT_LOCATIONS = [
      '.meatfile',
      '.boucher',
      '~/.meatfile',
      '~/.boucher',
    ]

    MEATFILE_NAME = 'Meatfile'

    attr_accessor :hostname
    attr_accessor :meatfile

    def initialize(args)
      @hostname = args.first
      @meatfile = hunt_for_meat
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

    # locate the Meatfile by traversing the current path
    # going up to root
    def hunt_for_meat

      raise "Meatfile not found" unless File.exists?(MEATFILE_NAME)

      @meatfile = MEATFILE_NAME

      # look for Meatfile:
      # recursor = lambda do |cur_path|
        # cur_path || recursor( File.join( cur_path, ))
      # end
      # cur_path = File.expand_path('./')
      # cur_path = File.join( cur_path, MEATFILE_NAME )

      # path =

      # look for other:

    end

  end
end
