require 'rexml/document'
require 'thread'
require 'uri'
require 'zlib'

module Sitemapper
  class Map < SitemapXML
    @@root_tag = 'urlset'

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
      self.locker.synchronize do
        loc = Sitemapper.urlfy(loc)
        lastmod, changefreq, priority = extract_options(opts)
        url = get_url(loc) || self.builder.root.add_element('url')
        (url.elements['loc'] || url.add_element('loc')).text = loc
        (url.elements['lastmod'] || url.add_element('lastmod')).text = lastmod.strftime('%Y-%m-%d') if lastmod
        (url.elements['changefreq'] || url.add_element('change_freq')).text = changefreq.to_s if changefreq
        (url.elements['priority'] || url.add_element('priority')).text = '%.2f' % priority if priority

        write_file
      end
    end
    alias map_path map_url

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

      self.locker.synchronize { write_file }
    end

    # Unmap the given localization (<tt>loc</tt>)
    #
    # * <tt>loc</tt> is the URL to be unmaped
    def unmap_url(loc)
      self.locker.synchronize do
        if url = get_url(Sitemapper.urlfy(loc))
          url.remove
          write_file
        end
      end
    end
    alias map_path map_url

    private

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
      self.builder.elements["//url[loc='#{url}']"]
    end
  end
end
