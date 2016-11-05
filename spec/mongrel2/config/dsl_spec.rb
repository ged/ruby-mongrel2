#!/usr/bin/env ruby

require_relative '../../helpers'

require 'rspec'
require 'mongrel2'
require 'mongrel2/config'


#####################################################################
###	C O N T E X T S
#####################################################################

describe Mongrel2::Config::DSL, :db do

	include described_class


	describe 'servers' do
		it "can generate a default server config using the 'server' declarative" do
			result = server '965A7196-99BC-46FA-945B-3478AE92BFB5'

			expect( result ).to be_a( Mongrel2::Config::Server )
			expect( result.uuid ).to eq( '965A7196-99BC-46FA-945B-3478AE92BFB5' )
		end


		it "can generate a more-elaborate server config using the 'server' declarative with a block" do
			result = server '965A7196-99BC-46FA-945B-3478AE92BFB5' do
				name 'Intranet'
				chroot '/service/mongrel2'
				access_log '/var/log/access'
				error_log '/var/log/errors'
				control_port '/var/run/intranet.sock'
			end

			expect( result ).to be_a( Mongrel2::Config::Server )
			expect( result.uuid ).to eq( '965A7196-99BC-46FA-945B-3478AE92BFB5' )
			expect( result.name ).to eq( 'Intranet' )
			expect( result.chroot ).to eq( '/service/mongrel2' )
			expect( result.access_log ).to eq( '/var/log/access' )
			expect( result.error_log ).to eq( '/var/log/errors' )
			expect( result.control_port ).to eq( '/var/run/intranet.sock' )
		end
	end

	describe 'hosts' do

		it "can add a host to a server config with the 'host' declarative" do
			result = server '965A7196-99BC-46FA-945B-3478AE92BFB5' do

				host 'localhost'

			end

			expect( result ).to be_a( Mongrel2::Config::Server )
			expect( result.hosts.size ).to eq(  1  )
			host = result.hosts.first

			expect( host ).to be_a( Mongrel2::Config::Host )
			expect( host.name ).to eq( 'localhost' )
		end

		it "can add several elaborately-configured hosts to a server via a block" do
			result = server '965A7196-99BC-46FA-945B-3478AE92BFB5' do

				host 'brillianttaste' do
					matching '*.brillianttasteinthefoodmouth.com'

					route '/images', directory( 'var/www/images/', 'index.html', 'image/jpeg' )
					route '/css', directory( 'var/www/css/', 'index.html', 'text/css' )
					route '/vote', proxy( 'localhost', 6667 )
					route '/admin', handler(
						'tcp://127.0.0.1:9998',
						'D613E7EE-E2EB-4699-A200-5C8ECAB45D5E'
					)

					dir_handler = handler(
						'tcp://127.0.0.1:9996',
						'B7EFA46D-FEE4-432B-B80F-E8A9A2CC6FDB',
						'tcp://127.0.0.1:9992',
						'protocol' => 'tnetstring'
					)
					route '@directory', dir_handler
					route '/directory', dir_handler
				end

				host 'deveiate.org' do
					route '', directory('usr/local/deveiate/www/public/', 'index.html')
				end

			end

			expect( result ).to be_a( Mongrel2::Config::Server )
			expect( result.hosts.size ).to eq(  2  )
			host1, host2 = result.hosts

			expect( host1 ).to be_a( Mongrel2::Config::Host )
			expect( host1.name ).to eq( 'brillianttaste' )
			expect( host1.matching ).to eq( '*.brillianttasteinthefoodmouth.com' )
			expect( host1.routes.size ).to eq(  6  )
			expect( host1.routes ).to all_be_a( Mongrel2::Config::Route )

			expect( host1.routes[0].path ).to eq( '/images' )
			expect( host1.routes[0].target ).to be_a( Mongrel2::Config::Directory )
			expect( host1.routes[0].target.base ).to eq( 'var/www/images/' )

			expect( host1.routes[1].path ).to eq( '/css' )
			expect( host1.routes[1].target ).to be_a( Mongrel2::Config::Directory )
			expect( host1.routes[1].target.base ).to eq( 'var/www/css/' )

			expect( host1.routes[2].path ).to eq( '/vote' )
			expect( host1.routes[2].target ).to be_a( Mongrel2::Config::Proxy )
			expect( host1.routes[2].target.addr ).to eq( 'localhost' )
			expect( host1.routes[2].target.port ).to eq( 6667 )

			expect( host1.routes[3].path ).to eq( '/admin' )
			expect( host1.routes[3].target ).to be_a( Mongrel2::Config::Handler )
			expect( host1.routes[3].target.send_ident ).to eq( 'D613E7EE-E2EB-4699-A200-5C8ECAB45D5E' )
			expect( host1.routes[3].target.send_spec ).to eq( 'tcp://127.0.0.1:9998' )
			expect( host1.routes[3].target.recv_ident ).to eq( '' )
			expect( host1.routes[3].target.recv_spec ).to eq( 'tcp://127.0.0.1:9997' )

			expect( host1.routes[4].path ).to eq( '@directory' )
			expect( host1.routes[4].target ).to be_a( Mongrel2::Config::Handler )
			expect( host1.routes[4].target.send_ident ).to eq( 'B7EFA46D-FEE4-432B-B80F-E8A9A2CC6FDB' )
			expect( host1.routes[4].target.send_spec ).to eq( 'tcp://127.0.0.1:9996' )
			expect( host1.routes[4].target.recv_spec ).to eq( 'tcp://127.0.0.1:9992' )
			expect( host1.routes[4].target.recv_ident ).to eq( '' )
			expect( host1.routes[4].target.protocol ).to eq( 'tnetstring' )

			expect( host1.routes[5].path ).to eq( '/directory' )
			expect( host1.routes[5].target ).to eq( host1.routes[4].target )

			expect( host2 ).to be_a( Mongrel2::Config::Host )
			expect( host2.name ).to eq( 'deveiate.org' )
			expect( host2.routes.size ).to eq(  1  )
			expect( host2.routes.first ).to be_a( Mongrel2::Config::Route )
		end


	end

	describe 'settings' do

		before( :all ) do
			@ids = Mongrel2::Config::Setting.map( :id )
		end

		after( :each ) do
			Mongrel2::Config::Setting.dataset.exclude( :id => @ids ).delete
		end

		it "can set the expert tweakable settings en masse" do
			result = settings(
				"zeromq.threads"         => 8,
				"upload.temp_store"      => "/home/zedshaw/projects/mongrel2/tmp/upload.XXXXXX",
				"upload.temp_store_mode" => "0666"
			)

			expect( result ).to be_an( Array )
			expect( result.size ).to eq(  3  )
			expect( result ).to all_be_a( Mongrel2::Config::Setting )
			expect( result[0].key ).to eq( 'zeromq.threads' )
			expect( result[0].value ).to eq( '8' )
			expect( result[1].key ).to eq( 'upload.temp_store' )
			expect( result[1].value ).to eq( '/home/zedshaw/projects/mongrel2/tmp/upload.XXXXXX' )
			expect( result[2].key ).to eq( 'upload.temp_store_mode' )
			expect( result[2].value ).to eq( '0666' )
		end

		it "can set a single expert setting" do
			result = setting "zeromq.threads", 16
			expect( result ).to be_a( Mongrel2::Config::Setting )
			expect( result.key ).to eq( 'zeromq.threads' )
			expect( result.value ).to eq( '16' )
		end

	end

	describe 'mimetypes' do

		it "can set new mimetype mappings en masse" do
			result = mimetypes(
				'.md'      => 'text/x-markdown',
				'.textile' => 'text/x-textile'
			)

			expect( result ).to be_an( Array )
			expect( result.size ).to eq(  2  )
			expect( result ).to all_be_a( Mongrel2::Config::Mimetype )
			expect( result[0].extension ).to eq( '.md' )
			expect( result[0].mimetype ).to eq( 'text/x-markdown' )
			expect( result[1].extension ).to eq( '.textile' )
			expect( result[1].mimetype ).to eq( 'text/x-textile' )
		end

		it "can set a single mimetype mapping" do
			result = mimetype '.tmpl', 'text/x-inversion-template'
			expect( result ).to be_a( Mongrel2::Config::Mimetype )
			expect( result.extension ).to eq( '.tmpl' )
			expect( result.mimetype ).to eq( 'text/x-inversion-template' )
		end

	end

	describe 'filters' do

		it "can add a filter to a server" do
			result = server '965A7196-99BC-46FA-945B-3478AE92BFB5' do
				filter '/usr/lib/mongrel2/null.so'
			end

			expect( result.filters.size ).to eq(  1  )
			expect( result.filters.first ).to be_a( Mongrel2::Config::Filter )
			expect( result.filters.first.settings ).to eq( {} )
		end

		it "can add a filter with settings to a server" do
			result = server '965A7196-99BC-46FA-945B-3478AE92BFB5' do
				filter '/usr/lib/mongrel2/null.so',
					extensions: ["*.html", "*.txt"],
					min_size: 1000
			end

			expect( result.filters.size ).to eq(  1  )
			expect( result.filters.first ).to be_a( Mongrel2::Config::Filter )
			expect( result.filters.first.settings ).
				to eq({ 'extensions' => ["*.html", "*.txt"], 'min_size' => 1000 })
		end

	end

	describe 'xrequests' do

		it "can add an xrequest to a server" do
			result = server '965A7196-99BC-46FA-945B-3478AE92BFB5' do
				xrequest '/usr/lib/mongrel2/null.so'
			end

			expect( result.xrequests.size ).to eq(  1  )
			expect( result.xrequests.first ).to be_a( Mongrel2::Config::XRequest )
			expect( result.xrequests.first.settings ).to eq( {} )
		end

		it "can add a filter with settings to a server" do
			result = server '965A7196-99BC-46FA-945B-3478AE92BFB5' do
				xrequest '/usr/lib/mongrel2/null.so',
					extensions: ["*.html", "*.txt"],
					min_size: 1000
			end

			expect( result.xrequests.size ).to eq(  1  )
			expect( result.xrequests.first ).to be_a( Mongrel2::Config::XRequest )
			expect( result.xrequests.first.settings ).
				to eq({ 'extensions' => ["*.html", "*.txt"], 'min_size' => 1000 })
		end

	end

end

