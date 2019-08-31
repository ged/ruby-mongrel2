#!/usr/bin/env ruby

require 'loggability'
Loggability.level = :fatal

require 'mongrel2/cli'
exit Mongrel2::CLI.run( ARGV )


