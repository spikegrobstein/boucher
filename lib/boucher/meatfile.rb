module Boucher
  module Meatfile

    class NotFound < StandardError; end

     # auxiliary meatfile paths
    MEAT_LOCATIONS = [
      '.meatfile',
      '.boucher',
      '~/.meatfile',
      '~/.boucher',
    ]

    MEATFILE_NAME = 'Meatfile'


    # locate the Meatfile by traversing the current path
    # going up to root
    def self.hunt_for_meat

      raise NotFound.new("Meatfile not found") unless File.exists?(MEATFILE_NAME)

      return MEATFILE_NAME

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
