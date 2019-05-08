# -*- ruby -*-
# frozen_string_literal: true
# coding: utf-8

require 'mongrel2' unless defined?( Mongrel2 )


### RSpec matchers for Mongrel2 specs
module Mongrel2::Matchers # :nodoc:

    ### A matcher for unordered array contents
	class EnumerableAllBeMatcher

		def initialize( expected_mod )
			@expected_mod = expected_mod
		end

		def matches?( collection )
			collection.all? {|obj| obj.is_a?(@expected_mod) }
		end

		def description
			return "all be a kind of %p" % [ @expected_mod ]
		end
	end


	###############
	module_function
	###############

	### Returns true if the actual value is an Array, all of which respond truly to
	### .is_a?( expected_mod )
	def all_be_a( expected_mod )
		EnumerableAllBeMatcher.new( expected_mod )
	end


end # module Mongrel2::Matchers


