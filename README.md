# Ruby-Mongrel2

home
: https://hg.sr.ht/~ged/ruby-mongrel2

code
: https://hg.sr.ht/~ged/ruby-mongrel2

github
: https://github.com/ged/ruby-mongrel2

docs
: https://deveiate.org/code/mongrel2



## Description

Ruby-Mongrel2 is a complete Ruby connector for Mongrel2[http://mongrel2.org/].

This library includes configuration-database ORM classes, a Ruby
implementation of the 'm2sh' tool, a configuration DSL for generating config
databases in pure Ruby, a Control port interface object, and handler classes
for creating applications or higher-level frameworks.


## Installation and Setup

Install mongrel2:

    $ {brew,port,portmaster,apt-get install,etc} mongrel2

Install the mongrel2 gem:

    $ gem install mongrel2

Dump a config database generation script into the current working directory:

    $ m2sh.rb bootstrap

Edit the generated file:

    $ $EDITOR config.rb

Create a config database from the Ruby config:

    $ m2sh.rb load config.rb

Start the server:

    $ m2sh.rb start

Or combine <tt>bootstrap</tt>, <tt>load</tt>, and <tt>start</tt> all into one
command:

    $ m2sh.rb quickstart


## Usage

The library consists of three major parts: the Config ORM classes, the
Handler classes, and the Control class.

### Config ORM Classes

There's one class per table like with most ORMs, a Mongrel2::Config::DSL mixin
for adding the Ruby configuration DSL to your namespace, and the top-level
Mongrel2::Config class, which manages the database connection, installs the
schema, etc.

The ORM classes use Jeremy Hinegardner's 'amalgalite' library, but it will
also fall back to using the sqlite3 library instead:

    # Loading the sqlite3 library explicitly
    $ rspec -rsqlite3 -cfp spec
    >>> Using SQLite3 1.3.4 for DB access.
    .....[...]

    Finished in 5.53 seconds
    102 examples, 0 failures

    # No -rsqlite3 means amalgalite loads first.
    $ rspec -cfp spec
    >>> Using Amalgalite 1.1.2 for DB access.
    .....[...]

    Finished in 3.67 seconds
    102 examples, 0 failures

For more detailed documentation, see:

* Mongrel2::Config
    * Mongrel2::Config::DSL
    * Mongrel2::Config::Server
    * Mongrel2::Config::Host
    * Mongrel2::Config::Route
    * Mongrel2::Config::Directory
    * Mongrel2::Config::Proxy
    * Mongrel2::Config::Handler
    * Mongrel2::Config::Setting
    * Mongrel2::Config::Mimetype
    * Mongrel2::Config::Statistic
    * Mongrel2::Config::Filter
    * Mongrel2::Config::Log


### Handler Classes

The main handler class is, unsurprisingly, Mongrel2::Handler. It uses a
Mongrel2::Connection object to talk to the server, wrapping the request data
up in a Mongrel2::Request object, and expecting a Mongrel2::Response to be
returned in response.

There are specialized Request classes for each of the kinds of requests
Mongrel2 sends:

* Mongrel2::HTTPRequest
* Mongrel2::JSONRequest
* Mongrel2::XMLRequest
* Mongrel2::WebSocket::ClientHandshake
* Mongrel2::WebSocket::Frame

These are all {overridable}[rdoc-ref:Mongrel2::Request.register_request_type]
if you should want a more-specialized class for one of them.

The Mongrel2::Handler class itself has documentation on how to write your own
handlers.


### The Control Class

The Mongrel2::Control class is an object interface to {the Mongrel2 control
port}[http://mongrel2.org/static/book-finalch4.html#x6-390003.8]. It can be
used to stop and restart the server, check its status, etc.


### Other Classes

There are a few other classes and modules worth checking out, too:

Mongrel2::Table::
  A hash-like data structure for headers, etc.
Mongrel2::Constants::
  A collection of convenience constants for Mongrel2 handlers.
Mongrel2::RequestFactory::
  A factory for generating fixtured requests of various types for testing.


## Contributing

You can check out the current development source with Mercurial via its
{project page}[https://hg.sr.ht/~ged/ruby-mongrel2]. Or if you
prefer Git, via {its Github mirror}[https://github.com/ged/ruby-mongrel2].

After checking out the source, run:

    $ rake setup

This task will install any missing dependencies and do any other setup
necessary to start development.


## Other Implementations

There are two other Mongrel2 Ruby libraries, +m2r+ +rack-mongrel2+.
This implementation differs from them in several ways:

* It doesn't come with a Rack handler, or Rails examples, or anything too
  fancy. I intend to build my own webby framework bits around Mongrel2, and
  I thought maybe someone else might want to as well. If you don't, well
  again, there are two other libraries for you.

* It includes configuration stuff. I want to make tools that use the Mongrel2
  config database, so I wrote config classes. Sequel::Model made it
  stupid-easy. There's also a DSL for generating a config database, too,
  mostly because I found it an interesting exercise, and I like the way it
  looks.


## Authors

* Michael Granger <ged@faeriemud.org>


## License

Copyright (c) 2011-2020, Michael Granger
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice,
  this list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright notice,
  this list of conditions and the following disclaimer in the documentation
  and/or other materials provided with the distribution.

* Neither the name of the author/s, nor the names of the project's
  contributors may be used to endorse or promote products derived from this
  software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

