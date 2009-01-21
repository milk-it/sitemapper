require 'zlib'
require 'stringio'

module Sitemapper
  class SitemapXML
    SCHEMA = 'http://www.sitemaps.org/schemas/sitemap/0.9' #:nodoc:
    INDENT = -1 #:nodoc:
    @@root_tag = nil

    # Initialize a map
    #
    # * <tt>file</tt> is the path to the (new or existent) sitemap.xml
    def initialize(file)
      @file = file
      @write = true
      @gzip = @file =~ /gz$/i
      initialize_map
    end

    protected

    def locker
      @locker ||= Mutex.new
    end

    def builder
      @builder
    end

    # Write the file to disk (run only synchronized with @locker)
    def write_file
      File.open(@file, 'w') do |file|
        content = ''
        @builder.write(content, INDENT)

        if @gzip
          gz = Zlib::GzipWriter.new(file)
          gz.write content
          gz.close
        else
          file.write(content)
        end
      end if @write
    end

    # Initialize the map (called on the boot, normally)
    def initialize_map
      @builder = REXML::Document.new(if File.exists?(@file)
        content = nil
        if @gzip
          Zlib::GzipReader.open(@file) {|gz| content = gz.read}
        else
          content = File.read(@file)
        end
        content
      else
        nil
      end)

      if @builder.root.nil?
        @builder << REXML::XMLDecl.new('1.0', 'UTF-8')
        @builder.add_element(@@root_tag, 'xmlns' => SCHEMA)
        write_file
      else
        raise InvalidMap unless @builder.root.attributes.key? 'xmlns'
      end
    end
  end

  class InvalidMap < StandardError; end
end
