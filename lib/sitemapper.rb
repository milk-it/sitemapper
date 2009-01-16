$:.unshift(File.dirname(__FILE__))
require 'sitemapper/helpers'
require 'sitemapper/map'
require 'sitemapper/accessors'
require 'sitemapper/object_mapper'

module Sitemapper
  MAJOR, MINOR, TINY = 0, 3, 0 #:nodoc:

  # Get the running version of Sitemapper
  def self.version
    [MAJOR, MINOR, TINY].join('.')
  end

  def self.map=(map)
    @map = map
  end

  def self.map
    @map or raise 'Uninitialized Sitemapper.map'
  end

  # Define the default meta lookup for objects on <tt>page</tt> helper
  #
  # <tt>lookup</tt> is a hash with the following options:
  #
  # * <tt>:desc</tt> method to look for page description
  # * <tt>:keywords</tt> method to look for page keywords
  # * <tt>:title</tt> method to look for page title
  #
  # All these arguments can be an Array, String or Symbol and will
  # be used to lookup a valid method when you call <tt>page</tt> using
  # something different of a Hash as argument. For example:
  #
  # <% page(@contact) %>
  #
  def self.meta_lookup=(lookup)
    @meta_lookup = lookup
  end

  def self.meta_lookup
    @meta_lookup || {
      :desc     => [:short_description, :description],
      :keywords => [:tag_list, :keywords],
      :title    => [:title, :name]
    }
  end
end
