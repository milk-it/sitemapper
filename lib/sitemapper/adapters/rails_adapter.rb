module Sitemapper
  module Adapters
    module RailsAdapter
      module RoutesMapperExtension
        def self.included(base)
          base.class_eval do
            alias_method_chain :named_route, :sitemap
            alias_method_chain :connect, :sitemap
            alias_method_chain :root, :sitemap
          end
          path = File.join(Rails.root, 'public', 'sitemap_static.xml.gz')
          File.unlink(path) if File.exists?(path)
          @@map = Sitemapper::map_index.build_map(path)
        end

        def named_route_with_sitemap(name, path, options = {})
          map_if_possible(path, options)
          named_route_without_sitemap(name, path, options)
        end

        def connect_with_sitemap(path, options = {})
          map_if_possible(path, options)
          connect_without_sitemap(path, options)
        end

        def root_with_sitemap(options = {})
          map_if_possible('/', options)
          root_without_sitemap(options)
        end

        private

        def map_if_possible(path, options)
          # Don't map dynamic URLs
          method = options[:conditions][:method] rescue :get
          # TODO: extract options to map
          unless path =~ /[:*]/ || method != :get
            @@map.map_path(path)
          end
        end
      end

      # Install routing hooks, view helpers and initialize the
      # sitemap.xml file
      def self.install!
        Sitemapper::site_root = ActionController::Base.relative_url_root rescue
                                    ActionController::AbstractRequest.relative_url_root
        Sitemapper::map_index = Sitemapper::MapIndex.new(File.join(Rails.root, 'public', 'sitemap_index.xml.gz'))
        Sitemapper::map = Sitemapper::map_index.build_map(File.join(Rails.root, 'public', 'sitemap_dynamic.xml.gz'))
        ActionController::Routing::RouteSet::Mapper.send :include, RoutesMapperExtension
        ActionView::Base.send :include, Sitemapper::Helpers
        ActionController::Base.send :include, Sitemapper::Accessors
      end
    end
  end
end
