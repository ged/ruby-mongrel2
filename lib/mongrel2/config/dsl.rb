# -*- ruby -*-
# frozen_string_literal: true

require 'loggability'

require 'mongrel2' unless defined?( Mongrel2 )
require 'mongrel2/config' unless defined?( Mongrel2::Config )

# See DSL.md for details on how to use this mixin.
module Mongrel2::Config::DSL

	# A decorator object that provides the DSL-ish interface to the various Config
	# objects. It derives its interface on the fly from columns of the class it's
	# created with and a DSLMethods mixin if the target class defines one.
	class Adapter
		extend Loggability

		# Loggability API -- set up logging under the 'mongrel2' log host
		log_to :mongrel2


		### Create an instance of the specified +targetclass+ using the specified +opts+
		### as initial values. The first pair of +opts+ will be used in the filter to
		### find any previous instance and delete it.
		def initialize( targetclass, opts={}, &block )
			self.log.debug "Wrapping a %p" % [ targetclass ]
			@targetclass = targetclass

			@target = @targetclass.find_or_new( opts, &block )
			self.decorate_with_column_declaratives( @target )
			self.decorate_with_custom_declaratives( @targetclass )
		end


		######
		public
		######

		# The decorated object
		attr_reader :target


		### Backport the singleton_class method if there isn't one.
		unless instance_methods.include?( :singleton_class )
			def singleton_class
				class << self; self; end
			end
		end

		### Add a declarative singleton method for the columns of the +adapted_object+.
		def decorate_with_column_declaratives( adapted_object )
			columns = adapted_object.columns
			self.log.debug "  decorating for columns: %s" % [ columns.map( &:to_s ).sort.join(', ') ]

			columns.each do |colname|

				# Create a method that will act as a writer if called with an
				# argument, and a reader if not.
				method_body = Proc.new do |*args|
					if args.empty?
						self.target.send( colname )
					else
						self.target.send( "#{colname}=", *args )
					end
				end

				# Install the method
				self.singleton_class.send( :define_method, colname, &method_body )
			end
		end


		### Mix in methods defined by the "DSLMethods" mixin defined by the class
		### of the object being adapted.
		def decorate_with_custom_declaratives( objectclass )
			return unless objectclass.const_defined?( :DSLMethods )
			self.singleton_class.send( :include, objectclass.const_get(:DSLMethods) )
		end


	end # class Adapter


	### Create a Mongrel2::Config::Server with the specified +uuid+, evaluate
	### the block (if given) within its context, and return it.
	def server( uuid, &block )
		adapter = nil

		Mongrel2.log.info "Ensuring db is set up..."
		Mongrel2::Config.init_database

		Mongrel2.log.info "Entering transaction for server %p" % [ uuid ]
		Mongrel2::Config.db.transaction do

			Mongrel2.log.debug "Server [%s] (block: %p)" % [ uuid, block ]
			adapter = Adapter.new( Mongrel2::Config::Server, uuid: uuid ) do |server|
			    server.access_log   ||= "/logs/access.log"
			    server.error_log    ||= "/logs/error.log"
			    server.pid_file     ||= "/run/mongrel2.pid"
			    server.default_host ||= "localhost"
			    server.port         ||= 8888

				server.hosts.each( &:destroy )
				server.filters.each( &:destroy )
				server.xrequests.each( &:destroy )
			end
			adapter.instance_eval( &block ) if block

			Mongrel2.log.info "  saving server %p..." % [ uuid ]
			adapter.target.save
		end

		return adapter.target
	end


	### Set the value of one of the 'Tweakable Expert Settings'
	def setting( key, val )
		Mongrel2::Config.init_database
		setting = Mongrel2::Config::Setting.find_or_create( key: key )
		setting.value = val
		setting.save
	end


	### Set some 'Tweakable Expert Settings' en masse
	def settings( hash )
		result = []

		Mongrel2::Config.db.transaction do
			hash.each do |key, val|
				result << setting( key, val )
			end
		end

		return result
	end


	### Set up a mimetype mapping between files with the given +extension+ and +mimetype+.
	def mimetype( extension, mimetype )
		Mongrel2::Config.init_database

		type = Mongrel2::Config::Mimetype.find_or_create( extension: extension )
		type.mimetype = mimetype
		type.save

		return type
	end


	### Set some mimetypes en masse.
	def mimetypes( hash )
		result = []

		Mongrel2::Config.db.transaction do
			hash.each do |ext, mimetype|
				result << mimetype( ext, mimetype )
			end
		end

		return result
	end

end # module Mongrel2::Config::DSL

