#-*- ruby -*-
#encoding: utf-8

require 'cztop'
require 'cztop/reactor'
require 'cztop/reactor/signal_handling'
require 'securerandom'
require 'loggability'

require 'mongrel2' unless defined?( Mongrel2 )
require 'mongrel2/config'

require 'mongrel2/request'
require 'mongrel2/httprequest'
require 'mongrel2/jsonrequest'
require 'mongrel2/xmlrequest'
require 'mongrel2/websocket'

# Mongrel2 Handler application class. Instances of this class are the applications
# which connection to one or more Mongrel2 routes and respond to requests.
#
# == Example
#
# A dumb, dead-simple example that just returns a plaintext 'Hello'
# document with a timestamp.
#
#     #!/usr/bin/env ruby
#
#     require 'mongrel2/handler'
#
#     class HelloWorldHandler < Mongrel2::Handler
#
#       ### The main method to override -- accepts requests and
#       ### returns responses.
#       def handle( request )
#           response = request.response
#
#           response.status = 200
#           response.headers.content_type = 'text/plain'
#           response.puts "Hello, world, it's #{Time.now}!"
#
#           return response
#       end
#
#     end # class HelloWorldHandler
#
#     HelloWorldHandler.run( 'helloworld-handler' )
#
# This assumes the Mongrel2 SQLite config database is in the current
# directory, and is named 'config.sqlite' (the Mongrel2 default), but
# if it's somewhere else, you can point the Mongrel2::Config class
# to it:
#
#     require 'mongrel2/config'
#     Mongrel2::Config.configure( :configdb => 'mongrel2.db' )
#
# Mongrel2 also includes support for Configurability, so you can
# configure it along with your database connection, etc. Just add a
# 'mongrel2' section to the config with a 'configdb' key that points
# to where the Mongrel2 SQLite config database lives:
#
#     # config.yaml
#     db:
#       uri: postgres://www@localhost/db01
#
#     mongrel2:
#       configdb: mongrel2.db
#
#     whatever_else:
#       ...
#
# Now just loading and installing the config configures Mongrel2 as
# well:
#
#     require 'configurability/config'
#
#     config = Configurability::Config.load( 'config.yml' )
#     config.install
#
# If the Mongrel2 config database isn't accessible, or you need to
# configure the Handler's two 0mq connections yourself for some
# reason, you can do that, too:
#
#     app = HelloWorldHandler.new( 'helloworld-handler',
#         'tcp://otherhost:9999', 'tcp://otherhost:9998' )
#     app.run
#
class Mongrel2::Handler
	extend Loggability
	include Mongrel2::Constants,
	        CZTop::Reactor::SignalHandling


	# Loggability API -- set up logging under the 'mongrel2' log host
	log_to :mongrel2


	# Signals we handle
	QUEUE_SIGS = [
		:INT, :TERM, :HUP, :USR1,
		# :TODO: :QUIT, :WINCH, :USR2, :TTIN, :TTOU
	] & Signal.list.keys.map( &:to_sym )


	### Create an instance of the handler using the config from the database with
	### the given +appid+ and run it.
	def self::run( appid )
		app = self.app_instance_for( appid )
		self.log.info "Running application %p: %p" % [ appid, app ]
		app.run
	end


	### Return an instance of the handler configured for the handler in the currently-loaded
	### Mongrel2 config that corresponds to +appid+.
	def self::app_instance_for( appid )
		send_spec, recv_spec = self.connection_info_for( appid )
		self.log.info "  config specs: %s <-> %s" % [ send_spec, recv_spec ]
		return new( appid, send_spec, recv_spec )
	end


	### Return the send_spec and recv_spec for the given +appid+ from the current configuration
	### database. Returns +nil+ if no Handler is configured with +appid+ as its +sender_id+.
	def self::connection_info_for( appid )
		self.log.debug "Looking up handler spec for appid %p" % [ appid ]
		hconfig = Mongrel2::Config::Handler.by_send_ident( appid ).first or
			raise ArgumentError, "no handler with a send_ident of %p configured" % [ appid ]

		self.log.debug "  found: %s" % [ hconfig.values ]
		return hconfig.send_spec, hconfig.recv_spec
	end


	#################################################################
	###	I N S T A N C E   M E T H O D S
	#################################################################

	### Create a new instance of the handler with the specified +app_id+, +send_spec+,
	### and +recv_spec+.
	def initialize( app_id, send_spec, recv_spec ) # :notnew:
		super() # To the signal handler mixin

		@app_id    = app_id

		@conn      = Mongrel2::Connection.new( app_id, send_spec, recv_spec )
		@reactor   = CZTop::Reactor.new
	end


	######
	public
	######

	##
	# The handler's Mongrel2::Connection object.
	attr_reader :conn

	##
	# The app ID the app was created with
	attr_reader :app_id

	##
	# The CZTop::Reactor that manages IO
	attr_reader :reactor


	### Run the handler.
	def run
		self.log.info "Starting up %p" % [ self ]

		self.reactor.register( @conn.request_sock, :read, &self.method(:on_socket_event) )
		self.with_signal_handler( self.reactor, *QUEUE_SIGS ) do
			self.start_accepting_requests
		end

		return self # For chaining
	ensure
		self.log.info "Done: %p" % [ self ]
		@conn.close if @conn
	end


	### Return the Mongrel2::Config::Handler that corresponds to this app's
	### appid, and its connection's send_spec and recv_spec.
	def handler_config
		return self.configured_handlers.where(
			send_spec: self.conn.sub_addr,
			recv_spec: self.conn.pub_addr
		).first
	end


	### Return the Mongrel2::Config::Handlers that corresponds to this app's
	### appid.
	def configured_handlers
		return Mongrel2::Config::Handler.by_send_ident( self.app_id )
	end


	### Return the Mongre2::Config::Routes for this Handler.
	def configured_routes
		handlers = self.configured_handlers
		return Mongrel2::Config::Route.where( target_id: handlers.select(:id) )
	end


	### Return the Mongrel2::Config::Hosts that have routes that point to this
	### Handler.
	def configured_hosts
		routes = self.configured_routes
		return Mongrel2::Config::Host.where( id: routes.select(:host_id) )
	end


	### Return the Mongrel2::Config::Servers that have hosts that have routes that
	### point to this Handler.
	def configured_servers
		hosts = self.configured_hosts
		return Mongrel2::Config::Server.where( id: hosts.select(:server_id) )
	end


	### Shut down the handler.
	def shutdown
		self.log.info "Shutting down."
		self.reactor.stop_polling
		@conn.close
	end


	### Restart the handler. You should override this if you want to re-establish
	### database connections, flush caches, or other restart-ey stuff.
	def restart
		self.log.info "Restarting"
		if (( old_conn = @conn ))
			self.reactor.unregister( old_conn.request_sock )
			@conn = @conn.dup
			self.reactor.register( @conn.request_sock, :read, &self.method(:on_socket_event) )

			self.log.debug "  conn %p -> %p" % [ old_conn, @conn ]
			old_conn.close
		end
	end


	### Start a loop, accepting a request and handling it.
	def start_accepting_requests
		self.log.info "Starting the request loop."
		self.reactor.start_polling( ignore_interrupts: true )
	end


	### Reactor callback -- handle an IO event.
	def on_socket_event( event )
		if event.readable?
			req = self.conn.receive
			self.accept_request( req )
		elsif event.writable?
			raise "Request socket became writable?!"
		else
			raise "Socket event was neither readable nor writable! (%s)" % [ event ]
		end
	end


	### Read a request from the connection and dispatch it.
	def accept_request( req )
		self.log.info( req.inspect )
		res = self.dispatch_request( req )

		if res
			self.log.info( res.inspect )
			@conn.reply( res ) unless @conn.closed?
		end
	ensure
		# Remove any temporarily spooled Mongrel2 files.
		begin
			if req && req.body && req.body.respond_to?( :path ) && req.body.path
				req.body.close unless req.body.closed?
				File.unlink( req.body.path )
			end
		rescue Errno::ENOENT => err
			self.log.debug "File already cleaned up: %s (%s)" % [ req.body.path, err.message ]
		end
	end


	### Invoke a handler method appropriate for the given +request+.
	def dispatch_request( request )
		if request.is_disconnect?
			self.log.debug "disconnect!"
			self.handle_disconnect( request )
			return nil

		elsif request.upload_started?
			self.log.debug "async upload start!"
			return self.handle_async_upload_start( request )

		else
			self.log.debug "%s request." % [ request.headers['METHOD'] ]
			case request
			when Mongrel2::WebSocket::ClientHandshake
				return self.handle_websocket_handshake( request )
			when Mongrel2::WebSocket::Frame
				return self.handle_websocket( request )
			when Mongrel2::HTTPRequest
				return self.handle( request )
			when Mongrel2::JSONRequest
				return self.handle_json( request )
			when Mongrel2::XMLRequest
				return self.handle_xml( request )
			else
				self.log.error "Unhandled request type %s (%p)" %
					[ request.headers['METHOD'], request.class ]
				return nil
			end
		end
	end


	### Returns a string containing a human-readable representation of the Handler suitable
	### for debugging.
	def inspect
		return "#<%p:0x%016x conn: %p>" % [
			self.class,
			self.object_id * 2,
			self.conn,
		]
	end


	#
	# :section: Handler Methods
	# These methods are the principle mechanism for defining the functionality of
	# your handler. The logic that dispatches to these methods is all contained in
	# the #dispatch_request method, so if you want to do something completely different,
	# you should override that instead.
	#

	### The main handler function: handle the specified HTTP +request+ (a Mongrel2::Request) and
	### return a response (Mongrel2::Response). If not overridden, this method returns a
	### '204 No Content' response.
	def handle( request )
		self.log.warn "No default handler; responding with '204 No Content'"
		response = request.response
		response.status = HTTP::NO_CONTENT

		return response
	end


	### Handle a JSON message +request+. If not overridden, JSON message ('@route')
	### requests are ignored.
	def handle_json( request )
		self.log.warn "Unhandled JSON message request (%p)" % [ request.headers.path ]
		return nil
	end


	### Handle an XML message +request+. If not overridden, XML message ('<route')
	### requests are ignored.
	def handle_xml( request )
		self.log.warn "Unhandled XML message request (%p)" % [ request.headers.pack ]
		return nil
	end


	### Handle a WebSocket frame in +request+. If not overridden, WebSocket connections are
	### closed with a policy error status.
	def handle_websocket( request )
		self.log.warn "Unhandled WEBSOCKET frame (%p)" % [ request.headers.path ]
		res = request.response
		res.make_close_frame( Mongrel2::WebSocket::CLOSE_POLICY_VIOLATION )

		self.conn.reply( res )
		self.conn.reply_close( request )

		return nil
	end


	### Handle a WebSocket handshake HTTP +request+. If not overridden, this method drops
	### the connection.
	def handle_websocket_handshake( handshake )
		self.log.warn "Unhandled WEBSOCKET_HANDSHAKE request (%p)" % [ handshake.headers.path ]
		self.conn.reply_close( handshake )

		return nil
	end


	### Handle a disconnect notice from Mongrel2 via the given +request+. Its return value
	### is ignored.
	def handle_disconnect( request )
		self.log.info "Connection %p closed." % [ request.conn_id ]
		return nil
	end


	### Handle an asynchronous upload start notification. These are sent to notify the
	### handler that a request that exceeds the server's <tt>limits.content_length</tt>
	### has been received. The default implementation cancels any such uploads by
	### replying with an empty string. If the request should be accepted, your handler
	### should override this and do nothing if the request should continue. You'll receive
	### a new request via the regular callback when the upload completes whose entity body
	### is open to the spooled file.
	def handle_async_upload_start( request )
		explanation = "If you wish to handle requests like this, either set your server's "
		explanation << "'limits.content_length' setting to a higher value than %d, or override " %
			 [ request.content_length ]
		explanation << "#handle_async_upload_start."

		self.log.warn "Async upload from %s dropped." % [ request.remote_ip ]
		self.log.info( explanation )

		self.conn.reply_close( request )

		return nil
	end


	#########
	protected
	#########

	#
	# :section: Signal Handling
	# These methods set up some behavior for starting, restarting, and stopping
	# your application when a signal is received. If you don't want signals to
	# be handled, override #handle_signal with an empty method.
	#

	### Handle signals.
	def handle_signal( sig )
		self.log.debug "Handling signal %s" % [ sig ]
		case sig
		when :INT, :TERM
			self.on_termination_signal( sig )

		when :HUP
			self.on_hangup_signal( sig )

		when :USR1
			self.on_user1_signal( sig )

		else
			self.log.warn "Unhandled signal %s" % [ sig ]
		end

	end


	### Handle a TERM signal. Shuts the handler down after handling any current request/s. Also
	### aliased to #on_interrupt_signal.
	def on_termination_signal( signo )
		self.log.warn "Terminated (%p)" % [ signo ]
		self.shutdown
	end
	alias_method :on_interrupt_signal, :on_termination_signal


	### Handle a HUP signal. The default is to restart the handler.
	def on_hangup_signal( signo )
		self.log.warn "Hangup (%p)" % [ signo ]
		self.restart
	end


	### Handle a USR1 signal. Writes a message to the log by default.
	def on_user1_signal( signo )
		self.log.info "Checkpoint: User signal."
	end

end # class Mongrel2::Handler

