# -*- ruby -*-
# frozen_string_literal: true

require 'mongrel2' unless defined?( Mongrel2 )
require 'mongrel2/config' unless defined?( Mongrel2::Config )

# Mongrel2 Proxy configuration class
class Mongrel2::Config::Proxy < Mongrel2::Config( :proxy )

	### As of Mongrel2/1.8.0:
	# CREATE TABLE proxy (id INTEGER PRIMARY KEY,
	#     addr TEXT,
	#     port INTEGER);


	### Return a description of the proxy.
	def to_s
		return "Proxy to %s:%d" % [ self.addr, self.port ]
	end

end # class Mongrel2::Config::Proxy

