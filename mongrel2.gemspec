# -*- encoding: utf-8 -*-
# stub: mongrel2 0.44.0.pre20150325100404 ruby lib

Gem::Specification.new do |s|
  s.name = "mongrel2"
  s.version = "0.44.0.pre20150325100404"

  s.required_rubygems_version = Gem::Requirement.new("> 1.3.1") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Michael Granger"]
  s.date = "2015-03-25"
  s.description = "Ruby-Mongrel2 is a complete Ruby connector for Mongrel2[http://mongrel2.org/].\n\nThis library includes configuration-database ORM classes, a Ruby\nimplementation of the 'm2sh' tool, a configuration DSL for generating config\ndatabases in pure Ruby, a Control port interface object, and handler classes\nfor creating applications or higher-level frameworks."
  s.email = ["ged@FaerieMUD.org"]
  s.executables = ["m2sh.rb"]
  s.extra_rdoc_files = ["DSL.rdoc", "History.rdoc", "Manifest.txt", "README.rdoc", "examples/README.txt", "DSL.rdoc", "History.rdoc", "README.rdoc"]
  s.files = [".autotest", ".simplecov", "ChangeLog", "DSL.rdoc", "History.rdoc", "Manifest.txt", "README.rdoc", "Rakefile", "bin/m2sh.rb", "data/mongrel2/bootstrap.html", "data/mongrel2/config.rb.in", "data/mongrel2/config.sql", "data/mongrel2/css/master.css", "data/mongrel2/index.html.in", "data/mongrel2/js/websock-test.js", "data/mongrel2/mimetypes.sql", "data/mongrel2/websock-test.html", "examples/Procfile", "examples/README.txt", "examples/async-upload.rb", "examples/config.rb", "examples/helloworld-handler.rb", "examples/request-dumper.rb", "examples/request-dumper.tmpl", "examples/run", "examples/sendfile.rb", "examples/ws-echo.rb", "lib/mongrel2.rb", "lib/mongrel2/config.rb", "lib/mongrel2/config/directory.rb", "lib/mongrel2/config/dsl.rb", "lib/mongrel2/config/filter.rb", "lib/mongrel2/config/handler.rb", "lib/mongrel2/config/host.rb", "lib/mongrel2/config/log.rb", "lib/mongrel2/config/mimetype.rb", "lib/mongrel2/config/proxy.rb", "lib/mongrel2/config/route.rb", "lib/mongrel2/config/server.rb", "lib/mongrel2/config/setting.rb", "lib/mongrel2/config/statistic.rb", "lib/mongrel2/config/xrequest.rb", "lib/mongrel2/connection.rb", "lib/mongrel2/constants.rb", "lib/mongrel2/control.rb", "lib/mongrel2/exceptions.rb", "lib/mongrel2/handler.rb", "lib/mongrel2/httprequest.rb", "lib/mongrel2/httpresponse.rb", "lib/mongrel2/jsonrequest.rb", "lib/mongrel2/request.rb", "lib/mongrel2/response.rb", "lib/mongrel2/table.rb", "lib/mongrel2/testing.rb", "lib/mongrel2/websocket.rb", "lib/mongrel2/xmlrequest.rb", "spec/constants.rb", "spec/helpers.rb", "spec/matchers.rb", "spec/mongrel2/config/directory_spec.rb", "spec/mongrel2/config/dsl_spec.rb", "spec/mongrel2/config/filter_spec.rb", "spec/mongrel2/config/handler_spec.rb", "spec/mongrel2/config/host_spec.rb", "spec/mongrel2/config/log_spec.rb", "spec/mongrel2/config/proxy_spec.rb", "spec/mongrel2/config/route_spec.rb", "spec/mongrel2/config/server_spec.rb", "spec/mongrel2/config/setting_spec.rb", "spec/mongrel2/config/statistic_spec.rb", "spec/mongrel2/config/xrequest_spec.rb", "spec/mongrel2/config_spec.rb", "spec/mongrel2/connection_spec.rb", "spec/mongrel2/constants_spec.rb", "spec/mongrel2/control_spec.rb", "spec/mongrel2/handler_spec.rb", "spec/mongrel2/httprequest_spec.rb", "spec/mongrel2/httpresponse_spec.rb", "spec/mongrel2/request_spec.rb", "spec/mongrel2/response_spec.rb", "spec/mongrel2/table_spec.rb", "spec/mongrel2/websocket_spec.rb", "spec/mongrel2/xmlrequest_spec.rb", "spec/mongrel2_spec.rb"]
  s.homepage = "https://bitbucket.org/ged/ruby-mongrel2"
  s.licenses = ["BSD"]
  s.rdoc_options = ["--main", "README.rdoc"]
  s.required_ruby_version = Gem::Requirement.new(">= 2.0.0")
  s.rubygems_version = "2.4.6"
  s.signing_key = "/Volumes/Keys/ged-private_gem_key.pem"
  s.summary = "Ruby-Mongrel2 is a complete Ruby connector for Mongrel2[http://mongrel2.org/]"

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<sequel>, ["~> 4.2"])
      s.add_runtime_dependency(%q<tnetstring>, ["~> 0.3"])
      s.add_runtime_dependency(%q<yajl-ruby>, ["~> 1.0"])
      s.add_runtime_dependency(%q<trollop>, ["~> 2.0"])
      s.add_runtime_dependency(%q<sysexits>, ["~> 1.1"])
      s.add_runtime_dependency(%q<rbczmq>, ["~> 1.7"])
      s.add_runtime_dependency(%q<loggability>, ["~> 0.5"])
      s.add_runtime_dependency(%q<sqlite3>, ["~> 1.3"])
      s.add_runtime_dependency(%q<libxml-ruby>, ["~> 2.7"])
      s.add_development_dependency(%q<hoe-mercurial>, ["~> 1.4"])
      s.add_development_dependency(%q<hoe-deveiate>, ["~> 0.6"])
      s.add_development_dependency(%q<hoe-highline>, ["~> 0.2"])
      s.add_development_dependency(%q<rdoc>, ["~> 4.0"])
      s.add_development_dependency(%q<amalgalite>, ["~> 1.3"])
      s.add_development_dependency(%q<configurability>, ["~> 2.0"])
      s.add_development_dependency(%q<simplecov>, ["~> 0.7"])
      s.add_development_dependency(%q<rdoc-generator-fivefish>, ["~> 0"])
      s.add_development_dependency(%q<hoe>, ["~> 3.13"])
    else
      s.add_dependency(%q<sequel>, ["~> 4.2"])
      s.add_dependency(%q<tnetstring>, ["~> 0.3"])
      s.add_dependency(%q<yajl-ruby>, ["~> 1.0"])
      s.add_dependency(%q<trollop>, ["~> 2.0"])
      s.add_dependency(%q<sysexits>, ["~> 1.1"])
      s.add_dependency(%q<rbczmq>, ["~> 1.7"])
      s.add_dependency(%q<loggability>, ["~> 0.5"])
      s.add_dependency(%q<sqlite3>, ["~> 1.3"])
      s.add_dependency(%q<libxml-ruby>, ["~> 2.7"])
      s.add_dependency(%q<hoe-mercurial>, ["~> 1.4"])
      s.add_dependency(%q<hoe-deveiate>, ["~> 0.6"])
      s.add_dependency(%q<hoe-highline>, ["~> 0.2"])
      s.add_dependency(%q<rdoc>, ["~> 4.0"])
      s.add_dependency(%q<amalgalite>, ["~> 1.3"])
      s.add_dependency(%q<configurability>, ["~> 2.0"])
      s.add_dependency(%q<simplecov>, ["~> 0.7"])
      s.add_dependency(%q<rdoc-generator-fivefish>, ["~> 0"])
      s.add_dependency(%q<hoe>, ["~> 3.13"])
    end
  else
    s.add_dependency(%q<sequel>, ["~> 4.2"])
    s.add_dependency(%q<tnetstring>, ["~> 0.3"])
    s.add_dependency(%q<yajl-ruby>, ["~> 1.0"])
    s.add_dependency(%q<trollop>, ["~> 2.0"])
    s.add_dependency(%q<sysexits>, ["~> 1.1"])
    s.add_dependency(%q<rbczmq>, ["~> 1.7"])
    s.add_dependency(%q<loggability>, ["~> 0.5"])
    s.add_dependency(%q<sqlite3>, ["~> 1.3"])
    s.add_dependency(%q<libxml-ruby>, ["~> 2.7"])
    s.add_dependency(%q<hoe-mercurial>, ["~> 1.4"])
    s.add_dependency(%q<hoe-deveiate>, ["~> 0.6"])
    s.add_dependency(%q<hoe-highline>, ["~> 0.2"])
    s.add_dependency(%q<rdoc>, ["~> 4.0"])
    s.add_dependency(%q<amalgalite>, ["~> 1.3"])
    s.add_dependency(%q<configurability>, ["~> 2.0"])
    s.add_dependency(%q<simplecov>, ["~> 0.7"])
    s.add_dependency(%q<rdoc-generator-fivefish>, ["~> 0"])
    s.add_dependency(%q<hoe>, ["~> 3.13"])
  end
end
