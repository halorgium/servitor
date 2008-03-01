require "open3"

module GitHosting
  module Commands
    class UploadPack < Command
      name "git-upload-pack"
      
      def open(&block)
        LOG.debug "repo_name: #{repo_name.inspect}" if LOG.debug?
        Dir.chdir(repo_path) do
          @stdin, @stdout, @stderr = Open3.popen3('git-upload-pack', '--strict', '--timeout=10', '.')
          @active = true
          begin
            yield @stdin, @stdout, @stderr
          ensure
            LOG.debug "Finished" if LOG.debug?
            [@stdin, @stdout, @stderr].each {|p| p.close unless p.closed?}
            @active = false
          end
        end
      end
      attr_reader :active
      
      def deliver(line)
        if active
          @stdin.puts line
        else
          LOG.error "Not active; Failed!"
        end
      end
      
      def process
        open do |stdin, stdout, stderr|
          until stdout.eof?
            data = stdout.read(1)
            if data
              #LOG.debug "Got data from stdout: #{data.inspect}" if LOG.debug?
              connection.send_data data
            end
          end
        end
      rescue Exception
        LOG.error "#{$!.class}: #{$!.message}"
        LOG.debug $!.backtrace.inspect
      end
            
      def repo_path
        File.expand_path(unsafe_repo_path)
      end
      
      def unsafe_repo_path
        "/Users/tim/Projects/git-hosting/base#{repo_name}"
      end
    end
  end
end