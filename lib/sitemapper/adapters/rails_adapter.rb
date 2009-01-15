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
          unless path =~ /[:*]/ || method != :get
            Sitemapper::map.map_url(path, Date.today, :monthly, 0.8)
          end
        end
      end

      # Install routing hooks, view helpers and initialize the
      # sitemap.xml file
      def self.install!
        Sitemapper::Map.site_root = ActionController::Base.relative_url_root rescue
                                    ActionController::AbstractRequest.relative_url_root
        Sitemapper::map = Sitemapper::Map.new(File.join(Rails.root, 'public', 'sitemap.xml'))
        ActionController::Routing::RouteSet::Mapper.send :include, RoutesMapperExtension
        ActionView::Base.send :include, Sitemapper::Helpers
        ActionController::Base.send :include, Sitemapper::Accessors
      end
    end
  end
end
