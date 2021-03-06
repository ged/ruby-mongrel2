#!/usr/bin/env ruby
#encoding: utf-8

require 'pathname'
require 'tmpdir'

# This is a Ruby script that will *generate* the SQLite database
# that Mongrel2 uses for its configuration. You can just as easily
# use Mongrel2's 'm2sh' and the Pythonish config syntax described
# in the manual if you prefer that.
#
# See the "Mongrel2 Config DSL" section of the API docs, and the "How A
# Config Is Structured" section of the manual for details
# on specific items:
#
# Mongrel2 Config DSL::
#   http://deveiate.org/code/mongrel2/DSL_rdoc.html
#
# How A Config Is Structured::
#   http://mongrel2.org/static/book-finalch4.html#x6-260003.4
#
# You can load this via the 'm2sh.rb' tool that comes with the 'mongrel2'
# gem:
#
#   m2sh.rb -c config.sqlite load config.rb

# Establish some directories
base_dir   = Pathname( '/Users/ged/source/ruby/Mongrel2' )
upload_dir = Pathname( Dir.tmpdir ) + 'm2spool'

# Main Mongrel2 server config
main = server 'main' do

	name         'Main'
	default_host 'localhost'
	chroot       base_dir

	# All of these values are relative to the 'chroot' value if Mongrel2
	# is started as root. If it's not, they're relative to the directory
	# it's started in.
	access_log   '/logs/access.log'
	error_log    '/logs/error.log'
	pid_file     '/var/run/mongrel2.pid'

	# This the address and port the server will listen on. You can
	# use '0.0.0.0' as the bind_addr to listen on all interfaces/IPs.
	bind_addr    '127.0.0.1'
	port         8113

	host 'localhost' do

		# Serve static content out of a 'public' subdirectory
		route '/', directory( "public/", 'index.html', 'text/html' )

		# Dynamic content is served via handler routes
		route '/hello', handler( 'tcp://127.0.0.1:9999',  'helloworld' )

	end

end

setting 'limits.content_length', 512 * 1024
setting 'control_port', 'ipc://var/run/mongrel2.sock'
setting 'upload.temp_store', upload_dir + 'mongrel2.upload.XXXXXX'

# Make relative directories so that starting as a regular user works
(base_dir + "./#{main.access_log}").dirname.mkpath
(base_dir + "./#{main.error_log}").dirname.mkpath
(base_dir + "./#{main.pid_file}").dirname.mkpath
mkdir_p( upload_dir )

