# /usr/bin/rackup
# vim: set ft=ruby :

$LOAD_PATH.unshift(::File.expand_path(::File.join(::File.dirname(__FILE__), 'lib')))
require 'todoit'
require 'rubygems'
require 'rack/contrib/bounce_favicon'

if env == "development"
  use ::Rack::Reloader 
end

use ::Rack::BounceFavicon
use ::Rack::ContentLength
run(::Todoit::Web::Handler.new({ :env => env }))
