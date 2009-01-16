module Sitemapper
  module Helpers
    # Set the page data for title and meta tags
    #
    # ==== Parameters
    # * <tt>:title</tt> the title of the page
    # * <tt>:desc</tt> the description of the current page
    # * <tt>:keywords</tt> the keywords that represent the current page
    #
    # ==== The parameter can also be an object that respond to (used preferentially on this order):
    # * <tt>title</tt> OR <tt>name</tt> (for title)
    # * <tt>short_description</tt> OR <tt>description</tt> (for description)
    # * <tt>tag_list</tt> OR <tt>keywords</tt> (for keywords)
    #
    # See <tt>page_meta</tt> for further information and examples.
    #
    def page(defs)
      @_title = defs.delete(:title)
      @_desc  = defs.delete(:desc)
      @_keys  = defs.delete(:keywords)
      return nil # dummies safe!
    end

    def page_with_object(defs) # :nodoc:
      return page_without_object(defs) if defs.is_a?(Hash)

      lookup_method = lambda do |obj, key|
        methods = obj.class.respond_to?(:sitemapper_config)? obj.class.sitemapper_config : Sitemapper.meta_lookup
        methods = methods[key]
        method = if methods.is_a?(Array)
          methods.find {|m| obj.respond_to?(m)}
        elsif methods.is_a?(String) || methods.is_a?(Symbol)
          methods
        end
        logger.debug(">>> #{method}")
        return method.nil?? nil : obj.send(method)
      end # Do you think it's ugly? You have to see my grandma in underwear

      @_title = lookup_method.call(defs, :title)
      @_desc  = lookup_method.call(defs, :desc)
      @_keys  = lookup_method.call(defs, :keywords)
    end
    alias_method :page_without_object, :page
    alias_method :page, :page_with_object

    # Returns the title of the page with the website title
    #
    # ==== Parameters
    #
    # * the first parameter is the website title
    # * the second parameter is a options hash:
    #   * <tt>:separator</tt> is the separator of the page and the website title
    #
    # See <tt>page_meta</tt> for further information and examples.
    #
    def title(title, opts={})
      separator = opts[:separator] || ' :: '
      content_tag(:title, @_title.nil?? title : "#{@_title}#{separator}#{title}")
    end

    # Returns the meta tags for the current page, for example:
    # 
    #   app/views/foo/bar.html.erb
    #
    #   page(:title => 'Foo bar!',
    #     :description => 'Lorem ipsum dollar sit amet',
    #     :keywords => 'lorem, ipsum dollar, sit, amet')
    #
    #   app/views/layouts/application.html.erb
    #
    #   ...
    #   <head>
    #       <%= title('My Webste') %>
    #       <%= page_meta %>
    #   </head>
    #   ...
    #
    # The example above will output the following on the rendered page:
    #
    #   ...
    #   <head>
    #       <title>Foo bar! :: My Website</title>
    #       <meta name="description" content="Lorem ipsum dollar sit amet" />
    #       <meta name="keywords" content="lore, ipsum dollar, sit, amet" />
    #   </head>
    #
    def page_meta
      res = ''
      res << tag(:meta, :name => 'description', :content => @_desc) if @_desc
      res << tag(:meta, :name => 'keywords', :content => @_keys) if @_desc
      return res
    end
  end
end
