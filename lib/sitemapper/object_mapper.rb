module Sitemapper
  module ObjectMapper
    attr_accessor :sitemapper_config
    alias map_fields sitemapper_config=
  end
end
