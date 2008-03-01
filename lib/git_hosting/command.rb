module GitHosting
  class Command
    def self.set
      @@set ||= []
    end
    
    def self.name(name)
      set << [self, name]
    end
    
    def self.find(raw_command)
      ary = set.find do |(klass,name)|
        raw_command =~ /^#{name} /
      end
      ary.first if ary
    end
    
    def initialize(connection)
      @connection = connection
    end
    attr_reader :connection
    
    def repo_name
      connection.raw_command.split(/ /, 2).last
    end
  end
end