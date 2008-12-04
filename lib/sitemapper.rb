module Sitemapper
  class << self
    def add_mapping(loc, last_update, changefreq, priority)
      @maps ||= []
      @maps.push [loc, last_update, changefreq, priority]
    end

    def write!
      # TODO: treat if the file already exist, and if it does, open and merge
      # with the current routes

      file = File.open(File.join(Rails.root, 'public', 'sitemap.xml'), 'w')
      bld = Builder::XmlMarkup.new(:target => file, :indent => 2)
      bld.instruct! :xml, :version => '1.0', :encoding => 'UTF-8'
      bld.urlset('xmlns' => 'http://www.sitemaps.org/schemas/sitemap/0.9') do
        @maps.each do |map|
          bld.url do
            bld.loc        map[0]
            bld.lastmod    map[1].to_formatted_s('%Y-%m-%d')
            bld.changefreq map[2].to_s
            bld.priority   map[3].to_s
          end
        end
      end
      file.close
    end

    def install!
      ActionController::Routing::RouteSet::Mapper.send :include, RoutesMapperExtension
      ActionController::Routing::RouteSet.send :include, RoutingExtension
    end
  end

  module RoutesMapperExtension
    def self.included(base)
      base.class_eval do
        alias_method_chain :named_route, :sitemap
        alias_method_chain :connect, :sitemap
        alias_method_chain :root, :sitemap
      end
    end

    def named_route_with_sitemap(name, path, options = {})
      Sitemapper.add_mapping("http://www.example.com/#{path}", Date.today, :monthly, 0.8)
      named_route_without_sitemap(name, path, options)
    end

    def connect_with_sitemap(path, options = {})
      connect_without_sitemap(path, options)
    end

    def root_with_sitemap(options = {})
      root_without_sitemap(options)
    end
  end

  module RoutingExtension
    def self.included(base)
      base.class_eval do
        alias_method_chain :install_helpers, :sitemap
      end
    end

    def install_helpers_with_sitemap
      Sitemapper.write!
      install_helpers_without_sitemap
    end
  end
end
