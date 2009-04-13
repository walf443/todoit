# /usr/bin/rackup
# vim: set ft=ruby :

$LOAD_PATH.unshift(::File.expand_path(::File.join(::File.dirname(__FILE__), 'lib')))
require 'todoit'
require 'rubygems'
require 'rack/contrib/bounce_favicon'

require 'securerandom' # hmm. it was encounterd Bus Error, if not this line.

use ::Rack::ContentLength
use ::Rack::BounceFavicon

if env == "development"
  use ::Rack::Reloader 
  use ::Todoit::Web::Middlewares::DebugScreen
end

run(::Todoit::Web::Handler.new({ :env => env }))
