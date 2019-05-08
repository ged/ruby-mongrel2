# -*- ruby -*-
# frozen_string_literal: true

require 'tnetstring'

require 'mongrel2' unless defined?( Mongrel2 )
require 'mongrel2/config' unless defined?( Mongrel2::Config )

# Mongrel2 X-Request configuration class
#
#   # Using the config DSL:
#   xrequest '/usr/local/lib/mongrel2/filters/watermark.so',
#       extensions: ['*.jpg', '*.png'],
#       src: '/usr/local/var/image/acme.png'
#
#   # Which is the same as:
#   Mongrel2::Config::XRequest.create(
#       name: '/usr/local/lib/mongrel2/filters/sendfile.so',
#       settings: {
#         min_size: 1000
#       }
#
#   # Or:
#   server.add_xrequest(
#       name: '/usr/local/lib/mongrel2/filters/sendfile.so',
#       settings: {
#         min_size: 1000
#       })
#
class Mongrel2::Config::XRequest < Mongrel2::Config( :xrequest )

	### As of Mongrel2/1.8.1:
	# CREATE TABLE xrequest (id INTEGER PRIMARY KEY,
	#     server_id INTEGER,
	#     name TEXT,
	#     settings TEXT);
	#

	many_to_one :server


	# Serialize the settings column as TNetStrings
	plugin :serialization, :tnetstring, :settings

end # class Mongrel2::Config::XRequest

