# -*- encoding: utf-8 -*-
# stub: mongrel2 0.52.0.pre20171121181830 ruby lib

Gem::Specification.new do |s|
  s.name = "mongrel2".freeze
  s.version = "0.52.0.pre20171121181830"

  s.required_rubygems_version = Gem::Requirement.new("> 1.3.1".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Michael Granger".freeze]
  s.cert_chain = ["certs/ged.pem".freeze]
  s.date = "2017-11-22"
  s.description = "Ruby-Mongrel2 is a complete Ruby connector for Mongrel2[http://mongrel2.org/].\n\nThis library includes configuration-database ORM classes, a Ruby\nimplementation of the 'm2sh' tool, a configuration DSL for generating config\ndatabases in pure Ruby, a Control port interface object, and handler classes\nfor creating applications or higher-level frameworks.".freeze
  s.email = ["ged@FaerieMUD.org".freeze]
  s.executables = ["m2sh.rb".freeze]
  s.extra_rdoc_files = ["DSL.rdoc".freeze, "History.rdoc".freeze, "Manifest.txt".freeze, "README.rdoc".freeze, "DSL.rdoc".freeze, "History.rdoc".freeze, "README.rdoc".freeze]
  s.files = [".autotest".freeze, ".simplecov".freeze, "ChangeLog".freeze, "DSL.rdoc".freeze, "History.rdoc".freeze, "Manifest.txt".freeze, "README.rdoc".freeze, "Rakefile".freeze, "bin/m2sh.rb".freeze, "data/mongrel2/config.rb.in".freeze, "data/mongrel2/config.sql".freeze, "data/mongrel2/mimetypes.sql".freeze, "lib/mongrel2.rb".freeze, "lib/mongrel2/config.rb".freeze, "lib/mongrel2/config/directory.rb".freeze, "lib/mongrel2/config/dsl.rb".freeze, "lib/mongrel2/config/filter.rb".freeze, "lib/mongrel2/config/handler.rb".freeze, "lib/mongrel2/config/host.rb".freeze, "lib/mongrel2/config/log.rb".freeze, "lib/mongrel2/config/mimetype.rb".freeze, "lib/mongrel2/config/proxy.rb".freeze, "lib/mongrel2/config/route.rb".freeze, "lib/mongrel2/config/server.rb".freeze, "lib/mongrel2/config/setting.rb".freeze, "lib/mongrel2/config/statistic.rb".freeze, "lib/mongrel2/config/xrequest.rb".freeze, "lib/mongrel2/connection.rb".freeze, "lib/mongrel2/constants.rb".freeze, "lib/mongrel2/control.rb".freeze, "lib/mongrel2/exceptions.rb".freeze, "lib/mongrel2/handler.rb".freeze, "lib/mongrel2/httprequest.rb".freeze, "lib/mongrel2/httpresponse.rb".freeze, "lib/mongrel2/jsonrequest.rb".freeze, "lib/mongrel2/request.rb".freeze, "lib/mongrel2/response.rb".freeze, "lib/mongrel2/table.rb".freeze, "lib/mongrel2/testing.rb".freeze, "lib/mongrel2/websocket.rb".freeze, "lib/mongrel2/xmlrequest.rb".freeze, "spec/constants.rb".freeze, "spec/helpers.rb".freeze, "spec/matchers.rb".freeze, "spec/mongrel2/config/directory_spec.rb".freeze, "spec/mongrel2/config/dsl_spec.rb".freeze, "spec/mongrel2/config/filter_spec.rb".freeze, "spec/mongrel2/config/handler_spec.rb".freeze, "spec/mongrel2/config/host_spec.rb".freeze, "spec/mongrel2/config/log_spec.rb".freeze, "spec/mongrel2/config/proxy_spec.rb".freeze, "spec/mongrel2/config/route_spec.rb".freeze, "spec/mongrel2/config/server_spec.rb".freeze, "spec/mongrel2/config/setting_spec.rb".freeze, "spec/mongrel2/config/statistic_spec.rb".freeze, "spec/mongrel2/config/xrequest_spec.rb".freeze, "spec/mongrel2/config_spec.rb".freeze, "spec/mongrel2/connection_spec.rb".freeze, "spec/mongrel2/constants_spec.rb".freeze, "spec/mongrel2/control_spec.rb".freeze, "spec/mongrel2/handler_spec.rb".freeze, "spec/mongrel2/httprequest_spec.rb".freeze, "spec/mongrel2/httpresponse_spec.rb".freeze, "spec/mongrel2/request_spec.rb".freeze, "spec/mongrel2/response_spec.rb".freeze, "spec/mongrel2/table_spec.rb".freeze, "spec/mongrel2/websocket_spec.rb".freeze, "spec/mongrel2/xmlrequest_spec.rb".freeze, "spec/mongrel2_spec.rb".freeze]
  s.homepage = "https://bitbucket.org/ged/ruby-mongrel2".freeze
  s.licenses = ["BSD-3-Clause".freeze]
  s.rdoc_options = ["--main".freeze, "README.rdoc".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.2.0".freeze)
  s.rubygems_version = "2.6.13".freeze
  s.summary = "Ruby-Mongrel2 is a complete Ruby connector for Mongrel2[http://mongrel2.org/]".freeze

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<cztop>.freeze, ["~> 0.11"])
      s.add_runtime_dependency(%q<cztop-reactor>.freeze, ["~> 0.3"])
      s.add_runtime_dependency(%q<libxml-ruby>.freeze, ["~> 3.0"])
      s.add_runtime_dependency(%q<loggability>.freeze, ["~> 0.12"])
      s.add_runtime_dependency(%q<sequel>.freeze, ["~> 5.2"])
      s.add_runtime_dependency(%q<sqlite3>.freeze, ["~> 1.3"])
      s.add_runtime_dependency(%q<sysexits>.freeze, ["~> 1.1"])
      s.add_runtime_dependency(%q<tnetstring>.freeze, ["~> 0.3"])
      s.add_runtime_dependency(%q<trollop>.freeze, ["~> 2.0"])
      s.add_runtime_dependency(%q<yajl-ruby>.freeze, ["~> 1.0"])
      s.add_development_dependency(%q<hoe-mercurial>.freeze, ["~> 1.4"])
      s.add_development_dependency(%q<hoe-deveiate>.freeze, ["~> 0.9"])
      s.add_development_dependency(%q<hoe-highline>.freeze, ["~> 0.2"])
      s.add_development_dependency(%q<amalgalite>.freeze, ["~> 1.5"])
      s.add_development_dependency(%q<configurability>.freeze, ["~> 3.1"])
      s.add_development_dependency(%q<simplecov>.freeze, ["~> 0.12"])
      s.add_development_dependency(%q<rdoc-generator-fivefish>.freeze, ["~> 0"])
      s.add_development_dependency(%q<rdoc>.freeze, ["~> 4.0"])
      s.add_development_dependency(%q<hoe>.freeze, ["~> 3.16"])
    else
      s.add_dependency(%q<cztop>.freeze, ["~> 0.11"])
      s.add_dependency(%q<cztop-reactor>.freeze, ["~> 0.3"])
      s.add_dependency(%q<libxml-ruby>.freeze, ["~> 3.0"])
      s.add_dependency(%q<loggability>.freeze, ["~> 0.12"])
      s.add_dependency(%q<sequel>.freeze, ["~> 5.2"])
      s.add_dependency(%q<sqlite3>.freeze, ["~> 1.3"])
      s.add_dependency(%q<sysexits>.freeze, ["~> 1.1"])
      s.add_dependency(%q<tnetstring>.freeze, ["~> 0.3"])
      s.add_dependency(%q<trollop>.freeze, ["~> 2.0"])
      s.add_dependency(%q<yajl-ruby>.freeze, ["~> 1.0"])
      s.add_dependency(%q<hoe-mercurial>.freeze, ["~> 1.4"])
      s.add_dependency(%q<hoe-deveiate>.freeze, ["~> 0.9"])
      s.add_dependency(%q<hoe-highline>.freeze, ["~> 0.2"])
      s.add_dependency(%q<amalgalite>.freeze, ["~> 1.5"])
      s.add_dependency(%q<configurability>.freeze, ["~> 3.1"])
      s.add_dependency(%q<simplecov>.freeze, ["~> 0.12"])
      s.add_dependency(%q<rdoc-generator-fivefish>.freeze, ["~> 0"])
      s.add_dependency(%q<rdoc>.freeze, ["~> 4.0"])
      s.add_dependency(%q<hoe>.freeze, ["~> 3.16"])
    end
  else
    s.add_dependency(%q<cztop>.freeze, ["~> 0.11"])
    s.add_dependency(%q<cztop-reactor>.freeze, ["~> 0.3"])
    s.add_dependency(%q<libxml-ruby>.freeze, ["~> 3.0"])
    s.add_dependency(%q<loggability>.freeze, ["~> 0.12"])
    s.add_dependency(%q<sequel>.freeze, ["~> 5.2"])
    s.add_dependency(%q<sqlite3>.freeze, ["~> 1.3"])
    s.add_dependency(%q<sysexits>.freeze, ["~> 1.1"])
    s.add_dependency(%q<tnetstring>.freeze, ["~> 0.3"])
    s.add_dependency(%q<trollop>.freeze, ["~> 2.0"])
    s.add_dependency(%q<yajl-ruby>.freeze, ["~> 1.0"])
    s.add_dependency(%q<hoe-mercurial>.freeze, ["~> 1.4"])
    s.add_dependency(%q<hoe-deveiate>.freeze, ["~> 0.9"])
    s.add_dependency(%q<hoe-highline>.freeze, ["~> 0.2"])
    s.add_dependency(%q<amalgalite>.freeze, ["~> 1.5"])
    s.add_dependency(%q<configurability>.freeze, ["~> 3.1"])
    s.add_dependency(%q<simplecov>.freeze, ["~> 0.12"])
    s.add_dependency(%q<rdoc-generator-fivefish>.freeze, ["~> 0"])
    s.add_dependency(%q<rdoc>.freeze, ["~> 4.0"])
    s.add_dependency(%q<hoe>.freeze, ["~> 3.16"])
  end
end
