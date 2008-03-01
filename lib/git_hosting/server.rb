module GitHosting
  class Server  
    def initialize(host = nil, port = nil)
      LOG.info "Started"

      @host = host || "127.0.0.1"
      @port = port ? port.to_i : 9418

      trap('INT')  { stop_everything }
      trap('TERM') { stop_everything }
    end
    attr_reader :host, :port

    def stop_everything
      LOG.close
      EventMachine.stop_event_loop
    end

    def run
      EventMachine.run do
        begin
          EventMachine.start_server(host, port, Connection) do |connection|
            connection.comm_inactivity_timeout = 30
          end
          
          #EventMachine.set_effective_user("git")
        end
      end
    end
  end
end