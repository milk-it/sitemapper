module Sitemapper
  module Accessors
    def map_url(url, opts={})
      Sitemapper::map.map_url(url, opts)
    end

    def map_path(path, opts={})
      Sitemapper::map.map_path(path, opts)
    end

    def unmap_url(url)
      Sitemapper::map.unmap_url(url)
    end

    def unmap_path(path)
      Sitemapper::map.unmap_path(path)
    end

    def map_urls
      Sitemapper::map.map_urls do
        yield
      end
    end
  end
end
