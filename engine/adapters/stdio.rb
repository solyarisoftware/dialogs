module ClientAdapter
  #
  # terminal adapter:
  # Stdio (puts/gets) 
  #
  module Terminal

    def self.create
      system 'clear'
    end  

    def self.read
      gets.chomp  
    end

    def self.write(value)
      puts value.to_s.green
    end
  end
end
