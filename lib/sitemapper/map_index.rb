# <?xml version="1.0" encoding="UTF-8"?>
# <sitemapindex xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
#   <sitemap>
#       <loc>http://www.example.com/sitemap1.xml.gz</loc>
#       <lastmod>2004-10-01T18:23:17+00:00</lastmod>
#   </sitemap>
#   <sitemap>
#       <loc>http://www.example.com/sitemap2.xml.gz</loc>
#       <lastmod>2005-01-01</lastmod>
#   </sitemap>
# </sitemapindex>
require 'rexml/document'
require 'thread'
require 'uri'
require 'zlib'

module Sitemapper
  class MapIndex < SitemapXML
    @@root_tag = 'sitemapindex'

    def build_map(file, url_or_path=nil, lastmod=nil)
      add_map(url_or_path || File.basename(file), lastmod)
      map = Map.new(file)
    end

    def add_map(url_or_path, lastmod=nil)
      self.locker.synchronize do
        url_or_path = Sitemapper.urlfy(url_or_path)
        map = get_sitemap(url_or_path) || self.builder.root.add_element('sitemap')
        (map.elements['loc'] || map.add_element('sitemap')).text = url_or_path
        (map.elements['lastmod'] || map.add_element('lastmod')).text = lastmod.strftime('%Y-%m-%d') if lastmod
      
        write_file
      end
    end

    def remove_map(url_or_path)
      self.locker.synchronize do
        if map = get_sitemap(Sitemapper.urlfy(url_or_path))
          map.remove
          write_file
        end
      end
    end

    private

    # Return the sitemap Element for the given <tt>url</tt>
    def get_sitemap(url)
      self.builder.elements["//sitemap[loc='#{url}']"]
    end
  end
end
