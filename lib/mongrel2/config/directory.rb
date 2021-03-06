# -*- ruby -*-
# frozen_string_literal: true

require 'mongrel2' unless defined?( Mongrel2 )
require 'mongrel2/config' unless defined?( Mongrel2::Config )

# Mongrel2 Directory (Dir) configuration class
class Mongrel2::Config::Directory < Mongrel2::Config( :directory )

	### As of Mongrel2/1.8.0:
	# CREATE TABLE directory (id INTEGER PRIMARY KEY,
	#     base TEXT,
	#     index_file TEXT,
	#     default_ctype TEXT,
	#     cache_ttl INTEGER DEFAULT 0);

	### Sequel validation callback: add errors if the record is invalid.
	def validate
		self.validate_base
		self.validate_index_file
		self.validate_default_ctype
		self.validate_cache_ttl
	end


	### Return a description of the directory.
	def to_s
		return "Directory %s(%s) {%s} [cache %ds]" % [
			self.base,
			self.index_file,
			self.default_ctype,
			self.cache_ttl
		]
	end


	#########
	protected
	#########

	### Validate the 'base' directory which will be served.
	def validate_base
		if self.base
			if self.base.start_with?( '/' )
				errmsg = "[%p]: shouldn't start with '/'; that will fail when not in chroot." %
					[ self.base ]
				self.log.error( 'base ' + errmsg )
				self.errors.add( :base, errmsg )
			end

			unless self.base.end_with?( '/' )
				errmsg = "[%p]: must end with '/' or it won't work right." %
					[ self.base ]
				self.log.error( 'base ' + errmsg )
				self.errors.add( :base, errmsg )
			end
		else
			errmsg = "missing or nil"
			self.log.error( 'base ' + errmsg )
			self.errors.add( :base, errmsg )
		end
	end


	### Validate the 'index_file' attribute.
	def validate_index_file
		self.validates_presence( :index_file, :message => "must not be nil" )
	end


	### Validate the index file attribute.
	def validate_default_ctype
		self.validates_presence( :default_ctype, :message => "must not be nil" )
	end


	### Validate the cache TTL if one is set.
	def validate_cache_ttl
		if self.cache_ttl && Integer( self.cache_ttl ) < 0
			errmsg = "[%p]: not a positive Integer" % [ self.cache_ttl ]
			self.log.error( 'cache_ttl' + errmsg )
			self.errors.add( :cache_ttl, errmsg )
		end
	end




end # class Mongrel2::Config::Directory

