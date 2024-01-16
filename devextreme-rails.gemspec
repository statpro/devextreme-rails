# -*- encoding: utf-8 -*-
# stub: devextreme-rails 22.1.6.pre.0.16 ruby lib

Gem::Specification.new do |s|
  s.name = "devextreme-rails".freeze
  s.version = "22.1.6.pre.0.16"

  s.required_rubygems_version = Gem::Requirement.new("> 1.3.1".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "allowed_push_host" => "'http://mygemserver.com'", "changelog_uri" => "https://github.com/StatProSA/devextreme-rails/changelog.md", "homepage_uri" => "https://github.com/StatProSA/devextreme-rails", "source_code_uri" => "https://github.com/StatProSA/devextreme-rails" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["StatPro Plc".freeze]
  s.bindir = "exe".freeze
  s.date = "2024-01-12"
  s.description = "Write a longer description or delete this line.".freeze
  s.email = ["support@statpro.com".freeze]
  s.files = [".github/workflows/publish.yml".freeze, ".gitignore".freeze, ".npmrc".freeze, ".rspec".freeze, ".travis.yml".freeze, "CODE_OF_CONDUCT.md".freeze, "Gemfile".freeze, "Gemfile.lock".freeze, "LICENSE.txt".freeze, "Makefile".freeze, "README.md".freeze, "Rakefile".freeze, "app/assets/fonts/dxicons.eot".freeze, "app/assets/fonts/dxicons.ttf".freeze, "app/assets/fonts/dxicons.woff".freeze, "app/assets/fonts/dxicons.woff2".freeze, "app/assets/fonts/dxiconsios.eot".freeze, "app/assets/fonts/dxiconsios.ttf".freeze, "app/assets/fonts/dxiconsios.woff".freeze, "app/assets/fonts/dxiconsios.woff2".freeze, "app/assets/fonts/dxiconsmaterial.ttf".freeze, "app/assets/fonts/dxiconsmaterial.woff".freeze, "app/assets/fonts/dxiconsmaterial.woff2".freeze, "app/assets/javascripts/cldr.js".freeze, "app/assets/javascripts/cldr/event.js".freeze, "app/assets/javascripts/cldr/supplemental.js".freeze, "app/assets/javascripts/cldr/unresolved.js".freeze, "app/assets/javascripts/data_table.js".freeze, "app/assets/javascripts/data_table_templates.js".freeze, "app/assets/javascripts/devextreme.js".freeze, "app/assets/javascripts/devextreme_jquery.js".freeze, "app/assets/javascripts/dx.webappjs.js".freeze, "app/assets/javascripts/globalize.js".freeze, "app/assets/javascripts/globalize/currency.js".freeze, "app/assets/javascripts/globalize/date.js".freeze, "app/assets/javascripts/globalize/message.js".freeze, "app/assets/javascripts/globalize/number.js".freeze, "app/assets/javascripts/master_detail.js".freeze, "app/assets/stylesheets/devextreme.css".freeze, "app/assets/stylesheets/dx.common.css".freeze, "app/assets/stylesheets/dx.light.css".freeze, "app/assets/stylesheets/master_detail.scss".freeze, "app/helpers/data_table_helper.rb".freeze, "app/helpers/icon_helper.rb".freeze, "app/helpers/layout_helper.rb".freeze, "app/src/javascripts/devextreme.js".freeze, "app/src/javascripts/devextreme_jquery.js".freeze, "app/src/stylesheets/devextreme.scss".freeze, "app/views/data_tables/_data_table.html.haml".freeze, "app/views/data_tables/_download_modal.html.haml".freeze, "app/views/data_tables/_grid_toolbar.html.haml".freeze, "app/views/data_tables/buttons/_back_button.html.haml".freeze, "app/views/layouts/_master_detail.html.haml".freeze, "bin/console".freeze, "bin/setup".freeze, "devextreme-rails.gemspec".freeze, "lib/data_table.rb".freeze, "lib/data_table_formatters.rb".freeze, "lib/devextreme-rails.rb".freeze, "lib/devextreme/rails.rb".freeze, "lib/devextreme/rails/version.rb".freeze, "lib/renderers/data_table_csv_renderer.rb".freeze, "lib/renderers/data_table_json_renderer.rb".freeze, "lib/renderers/data_table_xls_renderer.rb".freeze, "lib/renderers/data_table_xml_renderer.rb".freeze, "package.json".freeze]
  s.homepage = "https://github.com/StatProSA/devextreme-rails".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.4.10".freeze
  s.summary = "Write a short summary, because RubyGems requires one.".freeze

  s.installed_by_version = "3.4.10" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_development_dependency(%q<bundler>.freeze, ["~> 2.3.0"])
  s.add_development_dependency(%q<rake>.freeze, ["~> 13.0"])
  s.add_development_dependency(%q<rspec>.freeze, ["~> 3.0"])
end
