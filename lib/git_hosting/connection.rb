module GitHosting
  class Connection < EventMachine::Connection
    @@zomg = 0
    def post_init
      exit if @@zomg > 0
      @@zomg += 1
      @lines = []
      @lt2_delimiter = "\0"
    end
    attr_reader :lines
    
    include EventMachine::Protocols::LineText2
    
    def receive_line(line)
      if setting_up?
        lines << line
        LOG.debug "Line: #{line.inspect}"
        LOG.debug "raw_command: #{raw_command.inspect}"
        LOG.debug "command: #{command.inspect}"
        LOG.debug "host: #{host.inspect}"
        unless setting_up?
          raise "No such command" unless command
          start
        end
      else
        LOG.debug "Delivering line to command..." if LOG.debug?
        command.deliver line
      end
    rescue
      LOG.error "#{$!.class}: #{$!.message}"
      LOG.debug $!.backtrace.inspect
      close_connection
    end
    
    def setting_up?
      raw_command.nil? || host.nil?
    end
    
    def command
      @command ||= begin
        if klass = Command.find(raw_command)
          klass.new(self)
        end
      end
    end
    
    def raw_command
      @raw_command ||= command_line && command_line[4..-1]
    end
    
    def command_line
      lines.find {|l| l =~ /^[0-9a-f]{4}git-/}
    end
    
    def host
      @host ||= host_line && host_line.split(/=/).last
    end
    
    def host_line
      lines.find {|l| l =~ /^host=/}
    end

    def start
      @lt2_delimiter = "\n"
      LOG.debug "Starting..."
      processor = lambda do
        LOG.debug "Before"
        command.process
      end
      
      EventMachine.defer(processor)
    end
  end
end