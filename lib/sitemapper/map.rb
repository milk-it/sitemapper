require 'rexml/document'
require 'thread'
require 'uri'

module Sitemapper
  class Map
    SCHEMA = 'http://www.sitemaps.org/schemas/sitemap/0.9' #:nodoc:
    INDENT = -1 #:nodoc:

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

    # Initialize a map
    #
    # * <tt>file</tt> is the path to the (new or existent) sitemap.xml
    def initialize(file)
      @builder = REXML::Document.new(File.exists?(file)? File.read(file) : nil)
      @locker = Mutex.new
      @file = file
      @write = true
      initialize_map
    end

    # Map the given localization
    #
    # <tt>loc</tt> is the URL to me mapped
    # <tt>opts</tt> is a hash with the following parameters:
    #
    # * <tt>url</tt> or <tt>path</tt> is the complete URL or path (ex.: /articles/rails-doesnt-scale) [required]
    # * <tt>lastmod</tt> a date object to the last modification [optional]
    # * <tt>changefreq</tt> the frequency of change (:daily, :monthly, :yearly) [optional]
    # * <tt>priority</tt> the priority of the URL (0..1) [optional]
    #
    # See http://www.sitemaps.org/protocol.php
    def map_url(loc, opts={})
      @locker.synchronize do
        set_url_node(loc, opts)
        write_file
      end
    end

    # Map the given path
    #
    # <tt>path</tt> is the path to be mapped
    # <tt>opts</tt> is a hash containing options for this url (see <tt>map_url</tt>)
    def map_path(path, opts={})
      map_url(URI.join(Map.site_root, path), opts)
    end

    # Map multiple URLs and write once (at the end)
    #
    # Usage:
    # 
    #   map.map_urls do |map|
    #     map.map_url('http://www.example.com/about')
    #     map.unmap_url('http://www.example.com/contact')
    #   end
    #
    def map_urls
      @write = false
      yield(self)
      @write = true

      @locker.synchronize { write_file }
    end

    # Unmap the given localization (<tt>loc</tt>)
    #
    # * <tt>loc</tt> is the URL to be unmaped
    def unmap_url(loc)
      @locker.synchronize do
        unset_url_node(loc)
        write_file
      end
    end

    # Unmap the given path
    #
    # * <tt>loc</tt> is the Path t be unmaped
    def unmap_path(loc)
      unmap_url(URI.join(Map.site_root, loc))
    end

    private

    def set_url_node(loc, opts)
      lastmod, changefreq, priority = extract_options(opts)
      url = get_url(loc) || @builder.root.add_element('url')
      (url.elements['loc'] || url.add_element('loc')).text = loc
      (url.elements['lastmod'] || url.add_element('lastmod')).text = lastmod.strftime('%Y-%m-%d') if lastmod
      (url.elements['changefreq'] || url.add_element('change_freq')).text = changefreq.to_s if changefreq
      (url.elements['priority'] || url.add_element('priority')).text = '%.2f' % priority if priority
    end

    def unset_url_node(loc)
      url = get_url(loc)
      url.remove if url
    end

    # Extract the options to map an URL
    #
    # see <tt>map_url</tt> to understand.
    def extract_options(opts)
      lastmod = opts.delete(:lastmod)
      changefreq = opts.delete(:changefreq)
      priority = opts.delete(:priority)

      [lastmod, changefreq, priority]
    end

    # Return the Element for the given <tt>url</tt>
    def get_url(url)
      @builder.elements["//url[loc='#{url}']"]
    end

    # Write the file to disk (run only synchronized with @locker)
    def write_file
      File.open(@file, 'w') {|file| @builder.write(file, INDENT)} if @write
    end

    # Initialize the map (called on the boot, normally)
    def initialize_map
      if @builder.root.nil?
        @builder << REXML::XMLDecl.new('1.0', 'UTF-8')
        @builder.add_element('urlset', 'xmlns' => SCHEMA)
      else
        raise InvalidMap unless @builder.root.attributes.key? 'xmlns'
      end
    end
  end

  class InvalidMap < StandardError; end
end
