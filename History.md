# Release History for mongrel2

---
## v0.55.0 [2020-04-08] Michael Granger <ged@faeriemud.org>

- Un-hoeify, update for Ruby 2.7.
- Add a version subcommand


## v0.54.0 [2019-09-04] Michael Granger <ged@FaerieMUD.org>

Enhancements:

- Convert the CLI to use GLI instead of (deprecated) Trollop


## v0.53.0 [2019-05-07] Michael Granger <ged@FaerieMUD.org>

Enhancements:

- Modify to run with frozen string literals (Ruby >= 2.6).
- Add a #socket_id method to Mongrel2::Request and ::Response.
- Rewrite websocket functionality to make it easier to write servers
  that use it.


## v0.52.2 [2019-04-24] Michael Granger <ged@FaerieMUD.org>

Bugfixes:

- Don't set linger on the Connection sockets until they're closing
- Defer creation of the reactor in the handler until it's #run
- Add #extended_reply? predicate to Mongrel2::Request for cases where
  it's used as a response too


## v0.52.1 [2018-07-23] Michael Granger <ged@FaerieMUD.org>

Bugfixes:

- Fix version of dependency on cztop-reactor


## v0.52.0 [2018-07-21] Michael Granger <ged@FaerieMUD.org>

Enhancements:

- Refactor IO code to use cztop-reactor
- Fix use of Gem.datadir for newer Rubygems.


##  v0.51.0 [2017-11-15] Michael Granger <ged@FaerieMUD.org>

Enhancements:

- Support (require) Sequel 5
- Update libxml-ruby dependency to the latest

Bugfixes:

- Add missing config input file for the bootstrap command


## v0.50.2 [2017-07-05] Michael Granger <ged@FaerieMUD.org>

Bugfixes:

- Add missing require to Strelka::Handler.


##  v0.50.1 [2017-05-31] Michael Granger <ged@FaerieMUD.org>

Bugfixes:

- Pin Sequel to 4.45 to avoid breaking changes.
- Randomize the inproc selfpipe socket name (mainly useful for testing).


##  v0.50.0 [2017-04-24] Michael Granger <ged@FaerieMUD.org>

Bugfixes:

- Fix issues with (and require) Sequel 4.45+


##  v0.49.0 [2017-03-10] Michael Granger <ged@FaerieMUD.org>

Enhancements:

- Use the CZTop library instead of rbczmq for ZeroMQ sockets.


## v0.48.0 [2017-01-16] Mahlon E. Smith <mahlon@martini.nu>

Housekeeping:

- Removed explicit versions for .gems local development
- Bumped Configurability dependency.


## v0.47.0 [2016-11-23] Mahlon E. Smith <mahlon@martini.nu>

Enhancements:

- Close spooled request bodies at the end of the request lifecycle.


## v0.46.0 [2016-11-05] Michael Granger <ged@FaerieMUD.org>

Enhancements:

- Pull up config setup/teardown into the spec helper
- Cache config mimetype table


## v0.45.1 [2016-11-03] Michael Granger <ged@FaerieMUD.org>

Bugfixes:

- Fix the license name in the gemspec.
- Fix an order dependency in the specs.


## v0.45.0 [2016-11-03] Michael Granger <ged@FaerieMUD.org>

Bugfixes:

- Guard against HTTP requests with a nil body.size.
- Make Mongrel2::Config a proper abstract subclass of Sequel::Model.
- Raise ZMQ::Error on nil return from Connection#recv


## v0.44.0 [2016-01-20] Mahlon E. Smith <mahlon@martini.nu>

Enhancements:

- Ensure that Mongrel2 spool files are removed after the lifetime of a
  request.
- Add the newly proposed code specific to legal obstacles /
  censorship.

https://datatracker.ietf.org/doc/draft-ietf-httpbis-legally-
restricted-status/?include_text=1


## v0.43.2 [2015-03-25] Michael Granger <ged@FaerieMUD.org>

Bugfixes:

- Remove some duplicated status codes that warn under Ruby 2.2.
- Remove some debug logging that errors under Ruby 2.2.

## v0.43.1 (yanked: no signed tag)


## v0.43.0 [2014-12-17] Michael Granger <ged@FaerieMUD.org>

- Add a Mongrel2::Request#server_chroot
  Used to qualify filesystem paths relative to Mongrel's chroot for
  sendfile, async upload, etc.


## v0.42.0 [2014-08-27] Michael Granger <ged@FaerieMUD.org>

Add support for sending extended replies.


## v0.41.0 [2014-02-02] Michael Granger <ged@FaerieMUD.org>

- Convert back to rbczmq for modern mongrel2s
- Config introspection and cleanup.
  - Add Mongrel2::Config.mimetypes for fetching Mongrel2's mime-types
    table.
  - Add more config introspection to the Mongrel2::Handler class.
- Use LibXML instead of Nokogiri for XML request type


## v0.40.0 [2013-10-31] Michael Granger <ged@FaerieMUD.org>

- Move back to the zmq library, as rbczmq was too unstable.
- Drop the xrequest table when creating the config DB.


## v0.39.0 [2013-09-25] Michael Granger <ged@FaerieMUD.org>

- Replace stagnant zmq library with rbczmq.
- Add config support for 1.8.1's "X-Requests"


## v0.38.0 [2013-09-18] Michael Granger <ged@FaerieMUD.org>

- Update dependencies, add Gemfile.
- Update to Mongrel2 1.8.1 config schema.


## v0.37.0 [2013-09-13] Michael Granger <ged@FaerieMUD.org>

- Make explicitly-set 'nil' body also a bodiless response.
- Add support for Sequel 4.x


## v0.36.0 [2013-02-28] Michael Granger <ged@FaerieMUD.org>

- Fixes for Ruby 2.
- Fix status line for responses that have an explicit content-length.
  This is so HEAD responses, for example, don't get reset to '204 No
  Content' just because their body is empty.
- Convert ::for_uuid to a introspection-friendly dataset method.
- Only log if wrapping a non-String body in a StringIO
- Updated Config model dataset declarations for Sequel versions > 3.42.
- Fix the 'start' subcommand of m2sh.rb.


## v0.35.0 [2012-12-11] Michael Granger <ged@FaerieMUD.org>

- Allow WebSocket frames to be set to reserved opcodes
- Allow WebSocket opcodes to be set numerically
- Add a #socket_id method to all WebSocket frame types.
  * Created a Mongrel2::WebSocket::Methods mixin with the
    implementation of the method.
  * Included the new mixin in WebSocket::Frame,
    WebSocket::ClientHandshake, and WebSocket::ServerHandshake
- Ensure the ZMQ context is closed when #run exits.

## v0.34.0 [2012-10-17] Michael Granger <ged@FaerieMUD.org>

- Fix the multiple-server case in 'm2sh.rb start'
- Add support for the new (edge) 'url-scheme' header and add an #ssl?
  predicate build on it.
- Try to make examples more tolerant of being run from other
  directories
- Add (1.8.0ish) url-scheme header to the defaults in mongrel2/testing
- Remove some more chatty debug logging.


## v0.33.0 [2012-10-02] Michael Granger <ged@FaerieMUD.org>

- Implement deferred signal-handling for Mongrel2::Handler
- Update the examples/
- Squelch some of the noisier debug logging


## v0.32.0 [2012-09-18] Michael Granger <ged@FaerieMUD.org>

- Add a settings command for showing "expert" settings to m2sh.rb.
- Updating dependencies


## v0.31.1 [2012-08-20] Michael Granger <ged@FaerieMUD.org>

- Fix an error message in m2sh.rb.


## v0.31.0 [2012-07-30] Michael Granger <ged@FaerieMUD.org>

Improve Server control-socket pathing.

Mongrel2::Config::Server#control_socket will now check for it
under the chroot, and relative to the pwd, and will raise an
exception if no socket is found instead of just returning a
socket that's doomed to block forever.


## v0.30.1 [2012-07-27] Michael Granger <ged@FaerieMUD.org>

Documentation and packaging fixes. Switch to sqlite3 until
Amalgalite works until MacOS X again.


## v0.30.0 [2012-07-27] Michael Granger <ged@FaerieMUD.org>

- Add a static index page to the quickstart Dir directory.
- Make the failure to find a mongrel2 binary friendlier.
- Fix parameter name of ::by_send_ident for auto-mapping by the rest
  service.


## v0.29.0 [2012-07-13] Michael Granger <ged@FaerieMUD.org>

- Make m2sh.rb write audit log events for modifying actions
- Add a --why option to m2sh.rb to allow reasons for actions to be
  logged.
- Add a convenience delegator to Mongrel2::Config for logging an
  action.
- Finish Mongrel2::Config::Log method documentation
- Remove RDoc sections from Mongrel2::Config::Server, as they made
  stuff more difficult to find.
- Add Mongrel2::Config::Server#to_s
- Make stringified Log events only include parens if the event has a
  'why' field.
- Remove extraneous message from m2sh.rb's quickstart subcommand


## v0.28.0 [2012-07-12] Michael Granger <ged@FaerieMUD.org>

- Add Mongrel2::Config::Server pathname methods for the path 
  attributes (#access_log, #pid_file, etc.).
- Show the server's URL at startup
- Finish Config::Server API docs and add a predicate method for
  use_ssl
- Remove shell mode from m2sh.rb.


## v0.27.0 [2012-07-02] Michael Granger <ged@FaerieMUD.org>

- Adds support for websocket handshake in 'develop' branch.
- Adds 'bootstrap' and 'quickstart' commands to m2sh.rb.


## v0.26.0 [2012-06-26] Michael Granger <ged@FaerieMUD.org>

- Fix the derived path to the async upload body
- Add a default async upload handler method that cancels the upload


## v0.25.0 [2012-06-20] Michael Granger <ged@FaerieMUD.org>

NOTE: This revision contains non-backward-compatible changes to
Mongrel2::Request, Mongrel2::Response, and all subclasses.

- Convert request and response entity bodies to IOish objects instead of
  Strings.
- Finished implementation of Mongrel2 async upload API -- async-uploaded
  entity bodies now become File entity bodies of the
  "X-Mongrel2-Upload-Done" request.
- Add a few newer-rfc HTTP error codes.
- Add support for Content-type charsets.


## v0.24.0 [2012-05-31] Michael Granger <ged@FaerieMUD.org>

- Fix a bug when duping a Mongrel2::Table with immediate objects as values.
- Change Config.settings to a Table.
- Add support for Mongrel2 async uploads.


## v0.23.0 [2012-05-17] Michael Granger <ged@FaerieMUD.org>

- Add a convenience method to Mongrel2::Handler for fetching its
  associated config object.
- Fix typos in m2sh.rb's exception handler
- Bumping dependency on Loggability to 0.2.


## v0.22.1 [2012-05-07] Michael Granger <ged@FaerieMUD.org>

Fix loggability dependency version.


## v0.22.0 [2012-05-07] Michael Granger <ged@FaerieMUD.org>

- Convert to Loggability for logging.
- Add an option to bin/m2sh.rb to rewrite the mongrel2 port of a host
  on the fly at startup.


## v0.21.0 [2012-04-23] Michael Granger <ged@FaerieMUD.org>

- Rename the defaults for Mongrel2::Config.
  This was changed to conform with Configurability's defaults API. The
  old name was aliased to the new for backward-compatibility.
- Add a Mongrel2::HTTPRequest#remote_ip method. This should support
  both the current Mongrel (1.7.5) and the future plan for appended
  X-Forwarded-For headers. [mahlon]


## v0.20.3 [2012-04-12] Michael Granger <ged@FaerieMUD.org>

- Fix a require in mongrel2/testing.
- Assume paths passed to configure( :configdb ) should use SQLite.
- Move the "other implementations" section to the bottom of the README.
- Set API docs to use fivefish if available


## v0.20.2 [2012-04-10] Michael Granger <ged@FaerieMUD.org>

- Fix Mongrel2::Config.dbname.


## v0.20.1 [2012-03-28] Michael Granger <ged@FaerieMUD.org>

- Fix dependencies and the spec that fails when you run against the
  version of Sequel I was trying to fix in the previous release.


## v0.20.0 [2012-03-28] Michael Granger <ged@FaerieMUD.org>

- Fix the config DB for Sequel 3.34.

Note: This fix includes several API changes

- Mongrel2::Config.adapter_method is now .sqlite_adapter, and just
  returns the name of the appropriate adapter instead of a Method
  object that returns a Sequel::Database.
- Mongrel2::Config.pathname is now .dbname, and returns either a URI
  or a String, depending on how the database handle was created.

These changes also will make it easier to use alternative
configuration databases, e.g., when I get the PostgreSQL config
module working, it'll be easier to point the config model at it.


## v0.19.0 [2012-03-28] Michael Granger <ged@FaerieMUD.org>

- Make HTTPResponse default to a 200 status if there's a body.


## v0.18.0 [2012-03-28] Michael Granger <ged@FaerieMUD.org>

- Make the 'handler' DSL directive replace any existing handler with
  its send_ident.
- Add a validation to ensure that handler configs have unique send/recv
  specs and IDs.


## v0.17.0 [2012-03-18] Michael Granger <ged@FaerieMUD.org>

- Squelch logging of expected SQL errors.
  Errors are normal during Mongrel2::Config.db= and
  .database_initialized?, so add a new .without_sql_logging method for
  temporarily disabling SQL logging, and wrap that around the methods
  in quesion.
- Fix documentation for WebSocket#validate_control_frame


## v0.16.0 [2012-03-10] Michael Granger <ged@FaerieMUD.org>

- Add WebSocket (RFC6455) support


## v0.15.1 [2012-03-02] Michael Granger <ged@FaerieMUD.org>

- Make sure Mongrel2::Config::Host deletes cascade to their routes
- Init the database outside of the transaction in the "server" DSL
  method
- Remove the SAFE test from the request-dumper example
- Correct the line number of errors in configs loaded from m2sh.rb
- Log SQL to the logger at DEBUG level


## v0.15.0 [2012-02-27] Michael Granger <ged@FaerieMUD.org>

- Fix the Mongrel2::Config::Server.by_uuid dataset method to return a
  dataset instead of the instance.


## v0.14.0 [2012-02-27] Michael Granger <ged@FaerieMUD.org>

- Add an alias for #headers -> #header to Mongrel2::Request and
  Mongrel2::HTTPResponse.
- Add an OPTIONS request factory method to the Mongrel2::RequestFactory


## v0.13.0 [2012-02-24] Michael Granger <ged@FaerieMUD.org>

- Fix the ZMQ socket identifier used by Connection.
- Add missing slash in the control socket URI
- Add an argument so the helloworld handler can use another config DB
- Fix handling of NO CONTENT (204) responses.
  * Don't set a Content-type header
  * Omit the body even if there is one
  * Set the content-length to 0


## v0.12.0 [2012-02-17] Michael Granger <ged@FaerieMUD.org>

- Add bodiless response predicate to Mongrel2::HTTPResponse.
- Add #put and #delete factory methods to the Mongrel2::RequestFactory.
- Flesh out docs for the Filter config class.


## v0.11.0 [2012-02-15] Michael Granger <ged@FaerieMUD.org>

- Make the DSL declarations replace existing records.
- Flesh out the documentation for the DSL
- Provide convenience methods for resetting an HTTP request's
  Content-type and Content-encoding headers.


## v0.10.0 [2012-02-06] Michael Granger <ged@FaerieMUD.org>

This release includes updates for Mongrel 1.8 and finishes up the m2sh.rb tool.

- New config class: Mongrel2::Config::Filter
- New DSL directive inside a 'server' section: 'filter'
- New methods:
  * Mongrel2::Config.settings
  * Mongrel2::Server
    - #control_socket_uri
	- #control_socket
	- #pid_file_path
- Added a new Mongrel2::Constants::DEFAULT_CONTROL_SOCKET constant
- Finished implementation of the rest of the m2sh commands in the ruby
  analog
- Adding a "sudo" option to m2sh.rb to start the server as root
- Enable the json_serializer plugin for the config ORM classes
- Backing out the change to HTTPResponse to use the @body ivar: changed
  the negotiation


## v0.9.2 [2011-10-12] Michael Granger <ged@FaerieMUD.org>

Bugfix: dup instead of clone to get rid of frozen status.


## v0.9.1 [2011-10-12] Michael Granger <ged@FaerieMUD.org>

Bugfix: use a dup of the default content-type constant instead 
of the String itself.


## v0.9.0 [2011-10-12] Michael Granger <ged@FaerieMUD.org>

- Fix Mongrel2::Table not duping/cloning its internal values.
- Set a default Content-type header in HTTP responses


## v0.8.0 [2011-10-12] Michael Granger <ged@FaerieMUD.org>

- Split out the normalization of HTTP response headers into two
  methods for overriding.


## v0.7.0 [2011-10-09] Michael Granger <ged@FaerieMUD.org>

- Add an optional #request attribute to Mongrel2::Response and make
  Response.from_request set it. This is to make things like content-
  negotiation less of a pain in the ass.
- Log request and response both at INFO.


## v0.6.0 [2011-10-03] Michael Granger <ged@FaerieMUD.org>

Mongrel2::HTTPRequest enhancements.
- Added #body= for rewriting the entity body
- Added convenience methods for fetching the Content-type and Content-
  encoding headers: #content_type, #content_encoding
- Switched the specs to use Mongrel2::RequestFactory for making
  request objects


## v0.5.0 [2011-09-30] Michael Granger <ged@FaerieMUD.org>

Enhancements:
- Added support for POST and HEAD requests to Mongrel2::RequestFactory.


## v0.4.0 [2011-09-27] Michael Granger <ged@FaerieMUD.org>

Additions:
- Added Mongrel2::Config::Server.by_uuid( uuid )


## v0.3.1 [2011-09-27] Michael Granger <ged@FaerieMUD.org>

Bugfix:
- Measure the content-length of HTTPResponse in bytes, not characters.
- Log unhandled disconnect notices as INFO instead of WARN

Enhancements:
- Made a stringified connection show the useful parts of the inspect
  output


## v0.3.0 [2011-09-23] Michael Granger <ged@FaerieMUD.org>

- Mongrel2::Client fixes/documentation updates.
- Include FileUtils in the 'm2sh.rb load' context so configs 
  loaded by it can create run/log directories, etc.
- Mongrel2::Connection: Set SO_LINGER on the sockets so 
  closing the connection doesn't wait for unconsumed events.
- Add missing include to Mongrel2::Handler


## v0.2.4 [2011-09-21] Michael Granger <ged@FaerieMUD.org>

- Added a cleaned-up Mongrel2::Response#inspect like
  Mongrel2::Request.
- Correct body size in inspected request/response output.


## v0.2.3 [2011-09-21] Michael Granger <ged@FaerieMUD.org>

- Change the default response status from '200 OK' to '204 No Content'


## v0.2.2 [2011-09-19] Michael Granger <ged@FaerieMUD.org>

- Packaging fix


## v0.2.1 [2011-09-19] Michael Granger <ged@FaerieMUD.org>

- Add missing HTTP::CONTINUE constant.


## v0.2.0 [2011-09-18] Michael Granger <ged@FaerieMUD.org>

- Factor out the generically-useful RSpec helper functions into
  mongrel2/testing.rb and add a RequestFactory.
- Fix object ID in inspect output, clean up inspected Request/Response
  objects.
- Tightened up the mongrel2.org DSL example, remove the accidentally-
  committed adminserver part.
- Request dumper now runs under $SAFE = 1
- Revert examples back to using examples.sqlite
- Added a bit of CSS to the examples
- Config DSL: directory: Default the index file to index.html


## v0.1.2 [2011-09-16] Michael Granger <ged@FaerieMUD.org>

Fixed some header problems in Mongrel2::HTTPResponse:

- Re-calculate content-length and date headers on each render.
- Don't clear headers passed to the constructor.


## v0.1.1 [2011-11-14] Michael Granger <ged@FaerieMUD.org>

Update dependency to rbzmq-2.1.4 for ZMQ::Error.


## v0.1.0 [2011-11-14] Michael Granger <ged@FaerieMUD.org>

Memoize Mongrel2::Request#response, and add Mongrel2::Request.response_class to
allow for easy overriding of the response type.


## v0.0.2 [2011-11-13] Michael Granger <ged@FaerieMUD.org>

Added a shim to work around lack of ZMQ::Error in zmq-2.1.3.


## v0.0.1 [2011-09-12] Michael Granger <ged@FaerieMUD.org>

Initial release.

