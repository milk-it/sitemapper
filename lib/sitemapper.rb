$:.unshift(File.dirname(__FILE__))
require 'sitemapper/helpers'
require 'sitemapper/sitemap_xml'
require 'sitemapper/map'
require 'sitemapper/map_index'
require 'sitemapper/accessors'
require 'sitemapper/object_mapper'

module Sitemapper
  MAJOR, MINOR, PATCH = 0, 3, 0 #:nodoc:

  # Get the running version of Sitemapper
  def self.version
    [MAJOR, MINOR, PATCH].join('.')
  end

  def self.map=(map)
    @map = map
  end

  def self.map
    @map
  end

  def self.map_index=(index)
    @map_index = index
  end

  def self.map_index
    @map_index
  end
    
  # Returns the site root (previously defined with site_root=)
  def self.site_root
    @@site_root ||= 'http://www.example.com/' 
  end

  # Set the site root for the generated URLs
  #
  # * <tt>root</tt> is the root, (ex.: http://www.example.com)
  def self.site_root=(root)
    @@site_root = root
  end

  def self.urlfy(url_or_path)
    url_or_path =~ /^https?:/ ? url_or_path : URI.join(self.site_root, url_or_path)
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
