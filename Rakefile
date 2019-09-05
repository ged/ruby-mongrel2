#!/usr/bin/env rake

require 'rake/clean'
require 'rdoc/task'

begin
	require 'hoe'
rescue LoadError
	abort "This Rakefile requires 'hoe' (gem install hoe)"
end

GEMSPEC = 'mongrel2.gemspec'

Hoe.plugin :mercurial
Hoe.plugin :signing
Hoe.plugin :deveiate

Hoe.plugins.delete :rubyforge

hoespec = Hoe.spec 'mongrel2' do
	self.readme_file = 'README.rdoc'
	self.history_file = 'History.rdoc'
	self.extra_rdoc_files = Rake::FileList[ '*.rdoc' ]
	self.license 'BSD-3-Clause'

	self.developer 'Michael Granger', 'ged@FaerieMUD.org'

	self.dependency 'cztop', '~> 0.11'
	self.dependency 'cztop-reactor', '~> 0.6'
	self.dependency 'gli', '~> 2.19'
	self.dependency 'libxml-ruby', '~> 3.1'
	self.dependency 'loggability', '~> 0.14'
	self.dependency 'pastel', '~> 0.7'
	self.dependency 'sequel', '~> 5.2'
	self.dependency 'sqlite3', '~> 1.3'
	self.dependency 'sysexits', '~> 1.1'
	self.dependency 'tnetstring', '~> 0.3'
	self.dependency 'tty-prompt', '~> 0.19'
	self.dependency 'tty-table', '~> 0.11'
	self.dependency 'yajl-ruby', '~> 1.4'

	self.dependency 'amalgalite', '~> 1.5', :developer
	self.dependency 'configurability', '~> 3.4', :developer
	self.dependency 'hoe-deveiate', '~> 0.10', :developer
	self.dependency 'simplecov', '~> 0.12', :developer
	self.dependency 'rdoc-generator-fivefish', '~> 0', :developer

	self.require_ruby_version( '>=2.5.0' )
	self.hg_sign_tags = true if self.respond_to?( :hg_sign_tags= )
	self.check_history_on_release = true if self.respond_to?( :check_history_on_release= )
	self.rdoc_locations << "deveiate:/usr/local/www/public/code/#{remote_rdoc_dir}"
end

ENV['VERSION'] ||= hoespec.spec.version.to_s

# Ensure the specs pass before checking in
task 'hg:precheckin' => [ :check_history, :check_manifest, :gemspec, :spec ]


desc "Build a coverage report"
task :coverage do
	ENV["COVERAGE"] = 'yes'
	Rake::Task[:spec].invoke
end
CLOBBER.include( 'coverage' )


# Use the fivefish formatter for docs generated from development checkout
if File.directory?( '.hg' )
	require 'rdoc/task'

	Rake::Task[ 'docs' ].clear
	RDoc::Task.new( 'docs' ) do |rdoc|
	    rdoc.main = "README.rdoc"
	    rdoc.rdoc_files.include( "*.rdoc", "ChangeLog", "lib/**/*.rb" )
	    rdoc.generator = :fivefish
		rdoc.title = 'Ruby-Mongrel2'
	    rdoc.rdoc_dir = 'doc'
	end
end

task :gemspec => GEMSPEC
file GEMSPEC => [ __FILE__, 'Manifest.txt' ]
task GEMSPEC do |task|
	spec = $hoespec.spec
	spec.files.delete( '.gemtest' )
	spec.signing_key = nil
	spec.cert_chain = ['certs/ged.pem']
	spec.version = "#{spec.version.bump}.0.pre#{Time.now.strftime("%Y%m%d%H%M%S")}"
	File.open( task.name, 'w' ) do |fh|
		fh.write( spec.to_ruby )
	end
end

CLOBBER.include( GEMSPEC.to_s )

