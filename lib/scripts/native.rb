require File.dirname(__FILE__) + '/../git_hosting'
GitHosting::LOG.level = Logger::Severity.const_get(ENV["LEVEL"]) if ENV["LEVEL"]
GitHosting::LOG.error "Log level: #{GitHosting::LOG.level}"
GitHosting::Server.new(*ARGV).run
