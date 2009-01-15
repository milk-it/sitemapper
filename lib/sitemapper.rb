require 'sitemapper/helpers'
require 'sitemapper/map'
require 'sitemapper/accessors'

module Sitemapper
  MAJOR, MINOR, TINY = 0, 2, 0 #:nodoc:

  # Get the running version of Sitemapper
  def version
    [MAJOR, MINOR, TINY].join('.')
  end

  def self.map=(map)
    @map = map
  end

  def self.map
    @map or raise 'Uninitialized Sitemapper.map'
  end
end
