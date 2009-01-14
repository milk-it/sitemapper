require 'sitemapper'

if Object.const_defined?('Rails')
  require 'sitemapper/adapters/rails_adapter'
  Sitemapper::Adapters::RailsAdapter.install!
end
