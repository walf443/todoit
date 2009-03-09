require File.join(File.dirname(__FILE__), 'spec_helper')
require 'todoit'
require 'spec/fixture'

# create dummy constant for test.
module Todoit
  module Web
    module C
      module Foo; end
    end
  end
end

describe Todoit::Web::Dispatcher do
  with_fixtures :path => :expected do

    it ":path should dispatch :expected" do |path, expected|
      $web_context = Todoit::Web::Context.new({
        :request => Rack::Request.new({ 'PATH_INFO' => path })
      })
      Todoit::Web::Dispatcher.dispatch({}).should == expected
    end

    set_fixtures([
      [ { '/'             => { :controller => Todoit::Web::C::Root, :action => 'index' } }, 'root path' ],
      [ { '/foo'          => { :controller => Todoit::Web::C::Root, :action => 'foo' } },   'a action' ],
      [ { '/foo/bar'      => { :controller => Todoit::Web::C::Foo, :action => 'bar' } },   'controller and action' ],
    ])
  end
end
