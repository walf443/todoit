# /usr/bin/rackup
# vim: set ft=ruby :

$LOAD_PATH.unshift(::File.expand_path(::File.join(::File.dirname(__FILE__), 'lib')))
require 'todoit'

if env == "development"
  use ::Rack::Reloader 
end
use ::Rack::ContentLength
run(::Todoit::Web::Handler.new({ :env => env }))
