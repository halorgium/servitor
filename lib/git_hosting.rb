$:.unshift File.dirname(__FILE__)

require 'rubygems'
require 'logger'
require 'eventmachine'

require 'git_hosting/connection'
require 'git_hosting/command'
require 'git_hosting/commands/upload_pack'
require 'git_hosting/server'

module GitHosting
  LOG = Logger.new($stderr)
end

Thread.abort_on_exception = true