Gem::Specification.new do |s|
  s.name = "sitemapper"
  s.version = '0.3.0'
  s.specification_version = 2 if s.respond_to? :specification_version=
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Carlos Junior"]
  s.date = "2009-01-06"
  s.description = "Sitemapper helps you to apply SEO techniques on your Ruby on Rails application, including auto generation of a sitemap."
  s.email = ["carlos@milk-it.net"]
  s.extra_rdoc_files = ["README.rdoc", "MIT-LICENSE"]
  s.files = [
    "README.rdoc", "Rakefile", "MIT-LICENSE", "install.rb", "init.rb", "tasks/sitemaper_tasks.rake",

    "lib/sitemapper.rb", "lib/sitemapper/helpers.rb", "lib/sitemapper/map.rb",
    "lib/sitemapper/adapters/rails_adapter.rb"
  ]
  s.has_rdoc = true
  s.homepage = "http://redmine.milk-it.net/projects"
  s.post_install_message = %q{
  Thank you for using Sitemapper.

  Consider help us to maintain Sitemapper by donating (github.com/milk-it/sitemapper) if you like it!
}
  s.rdoc_options = ['--line-numbers', '--inline-source', '--main', 'README.rdoc', '--title', 'Sitemapper']
  s.require_paths = ["lib"]
  s.rubyforge_project = "sitemapper"
  s.rubygems_version = "1.1.1"
  s.summary = s.description
  s.test_files = ["test/sitemapper_test.rb"]

  s.add_dependency("rails", [">= 2.1"])
end
