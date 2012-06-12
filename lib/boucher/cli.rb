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
    end

    def run!

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
