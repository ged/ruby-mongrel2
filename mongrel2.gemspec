# -*- encoding: utf-8 -*-
# stub: mongrel2 0.55.0.pre.20200407181552 ruby lib

Gem::Specification.new do |s|
  s.name = "mongrel2".freeze
  s.version = "0.55.0.pre.20200407181552"

  s.required_rubygems_version = Gem::Requirement.new("> 1.3.1".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "bug_tracker_uri" => "https://todo.sr.ht/~ged/ruby-mongrel2", "changelog_uri" => "https://deveiate.org/code/mongrel2/History_md.html", "documentation_uri" => "https://deveiate.org/code/mongrel2", "homepage_uri" => "https://hg.sr.ht/~ged/ruby-mongrel2", "source_uri" => "https://hg.sr.ht/~ged/ruby-mongrel2" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Michael Granger".freeze]
  s.date = "2020-04-07"
  s.description = "Ruby-Mongrel2 is a complete Ruby connector for Mongrel2.".freeze
  s.email = ["ged@faeriemud.org".freeze]
  s.executables = ["m2sh.rb".freeze]
  s.files = [".simplecov".freeze, "DSL.md".freeze, "History.md".freeze, "Manifest.txt".freeze, "README.md".freeze, "Rakefile".freeze, "bin/m2sh.rb".freeze, "data/mongrel2/config.rb.in".freeze, "data/mongrel2/config.sql".freeze, "data/mongrel2/mimetypes.sql".freeze, "gem.deps.rb".freeze, "lib/mongrel2.rb".freeze, "lib/mongrel2/cli.rb".freeze, "lib/mongrel2/cli/access.rb".freeze, "lib/mongrel2/cli/bootstrap.rb".freeze, "lib/mongrel2/cli/commit.rb".freeze, "lib/mongrel2/cli/hosts.rb".freeze, "lib/mongrel2/cli/init.rb".freeze, "lib/mongrel2/cli/load.rb".freeze, "lib/mongrel2/cli/log.rb".freeze, "lib/mongrel2/cli/quickstart.rb".freeze, "lib/mongrel2/cli/reload.rb".freeze, "lib/mongrel2/cli/routes.rb".freeze, "lib/mongrel2/cli/running.rb".freeze, "lib/mongrel2/cli/servers.rb".freeze, "lib/mongrel2/cli/settings.rb".freeze, "lib/mongrel2/cli/start.rb".freeze, "lib/mongrel2/cli/stop.rb".freeze, "lib/mongrel2/config.rb".freeze, "lib/mongrel2/config/directory.rb".freeze, "lib/mongrel2/config/dsl.rb".freeze, "lib/mongrel2/config/filter.rb".freeze, "lib/mongrel2/config/handler.rb".freeze, "lib/mongrel2/config/host.rb".freeze, "lib/mongrel2/config/log.rb".freeze, "lib/mongrel2/config/mimetype.rb".freeze, "lib/mongrel2/config/proxy.rb".freeze, "lib/mongrel2/config/route.rb".freeze, "lib/mongrel2/config/server.rb".freeze, "lib/mongrel2/config/setting.rb".freeze, "lib/mongrel2/config/statistic.rb".freeze, "lib/mongrel2/config/xrequest.rb".freeze, "lib/mongrel2/connection.rb".freeze, "lib/mongrel2/constants.rb".freeze, "lib/mongrel2/control.rb".freeze, "lib/mongrel2/exceptions.rb".freeze, "lib/mongrel2/handler.rb".freeze, "lib/mongrel2/httprequest.rb".freeze, "lib/mongrel2/httpresponse.rb".freeze, "lib/mongrel2/jsonrequest.rb".freeze, "lib/mongrel2/request.rb".freeze, "lib/mongrel2/response.rb".freeze, "lib/mongrel2/table.rb".freeze, "lib/mongrel2/testing.rb".freeze, "lib/mongrel2/websocket.rb".freeze, "lib/mongrel2/xmlrequest.rb".freeze, "spec/constants.rb".freeze, "spec/helpers.rb".freeze, "spec/matchers.rb".freeze, "spec/mongrel2/config/directory_spec.rb".freeze, "spec/mongrel2/config/dsl_spec.rb".freeze, "spec/mongrel2/config/filter_spec.rb".freeze, "spec/mongrel2/config/handler_spec.rb".freeze, "spec/mongrel2/config/host_spec.rb".freeze, "spec/mongrel2/config/log_spec.rb".freeze, "spec/mongrel2/config/proxy_spec.rb".freeze, "spec/mongrel2/config/route_spec.rb".freeze, "spec/mongrel2/config/server_spec.rb".freeze, "spec/mongrel2/config/setting_spec.rb".freeze, "spec/mongrel2/config/statistic_spec.rb".freeze, "spec/mongrel2/config/xrequest_spec.rb".freeze, "spec/mongrel2/config_spec.rb".freeze, "spec/mongrel2/connection_spec.rb".freeze, "spec/mongrel2/constants_spec.rb".freeze, "spec/mongrel2/control_spec.rb".freeze, "spec/mongrel2/handler_spec.rb".freeze, "spec/mongrel2/httprequest_spec.rb".freeze, "spec/mongrel2/httpresponse_spec.rb".freeze, "spec/mongrel2/request_spec.rb".freeze, "spec/mongrel2/response_spec.rb".freeze, "spec/mongrel2/table_spec.rb".freeze, "spec/mongrel2/testing_spec.rb".freeze, "spec/mongrel2/websocket_spec.rb".freeze, "spec/mongrel2/xmlrequest_spec.rb".freeze, "spec/mongrel2_spec.rb".freeze]
  s.homepage = "https://hg.sr.ht/~ged/ruby-mongrel2".freeze
  s.licenses = ["BSD-3-Clause".freeze]
  s.rubygems_version = "3.1.2".freeze
  s.summary = "Ruby-Mongrel2 is a complete Ruby connector for Mongrel2.".freeze

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<cztop>.freeze, ["~> 0.14"])
    s.add_runtime_dependency(%q<cztop-reactor>.freeze, ["~> 0.9"])
    s.add_runtime_dependency(%q<gli>.freeze, ["~> 2.19"])
    s.add_runtime_dependency(%q<libxml-ruby>.freeze, ["~> 3.1"])
    s.add_runtime_dependency(%q<loggability>.freeze, ["~> 0.17"])
    s.add_runtime_dependency(%q<pastel>.freeze, ["~> 0.7"])
    s.add_runtime_dependency(%q<rdoc-generator-fivefish>.freeze, ["~> 0.4"])
    s.add_runtime_dependency(%q<sequel>.freeze, ["~> 5.30"])
    s.add_runtime_dependency(%q<sqlite3>.freeze, ["~> 1.4"])
    s.add_runtime_dependency(%q<sysexits>.freeze, ["~> 1.2"])
    s.add_runtime_dependency(%q<tnetstring>.freeze, ["~> 0.3"])
    s.add_runtime_dependency(%q<tty-prompt>.freeze, ["~> 0.20"])
    s.add_runtime_dependency(%q<tty-table>.freeze, ["~> 0.11"])
    s.add_runtime_dependency(%q<yajl-ruby>.freeze, ["~> 1.4"])
    s.add_development_dependency(%q<amalgalite>.freeze, ["~> 1.6"])
    s.add_development_dependency(%q<configurability>.freeze, ["~> 4.1"])
    s.add_development_dependency(%q<rake-deveiate>.freeze, ["~> 0.12"])
    s.add_development_dependency(%q<rdoc-generator-fivefish>.freeze, ["~> 0.4"])
    s.add_development_dependency(%q<simplecov>.freeze, ["~> 0.18"])
  else
    s.add_dependency(%q<cztop>.freeze, ["~> 0.14"])
    s.add_dependency(%q<cztop-reactor>.freeze, ["~> 0.9"])
    s.add_dependency(%q<gli>.freeze, ["~> 2.19"])
    s.add_dependency(%q<libxml-ruby>.freeze, ["~> 3.1"])
    s.add_dependency(%q<loggability>.freeze, ["~> 0.17"])
    s.add_dependency(%q<pastel>.freeze, ["~> 0.7"])
    s.add_dependency(%q<rdoc-generator-fivefish>.freeze, ["~> 0.4"])
    s.add_dependency(%q<sequel>.freeze, ["~> 5.30"])
    s.add_dependency(%q<sqlite3>.freeze, ["~> 1.4"])
    s.add_dependency(%q<sysexits>.freeze, ["~> 1.2"])
    s.add_dependency(%q<tnetstring>.freeze, ["~> 0.3"])
    s.add_dependency(%q<tty-prompt>.freeze, ["~> 0.20"])
    s.add_dependency(%q<tty-table>.freeze, ["~> 0.11"])
    s.add_dependency(%q<yajl-ruby>.freeze, ["~> 1.4"])
    s.add_dependency(%q<amalgalite>.freeze, ["~> 1.6"])
    s.add_dependency(%q<configurability>.freeze, ["~> 4.1"])
    s.add_dependency(%q<rake-deveiate>.freeze, ["~> 0.12"])
    s.add_dependency(%q<rdoc-generator-fivefish>.freeze, ["~> 0.4"])
    s.add_dependency(%q<simplecov>.freeze, ["~> 0.18"])
  end
end
