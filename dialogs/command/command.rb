#
# command.rb
#
module Dialogs 
  #
  # List available dialogs/commands
  #
  class Command < Dialog

    def self.initialize_data
      nil
    end  

    #
    # state: start
    #
    def start(text)
      go :command, command_o
    end  

    #
    # state: command
    #
    def command(text)
      case text
      when order_i
        # assign data with command
        #self.data = text

        # pass to a new dialog
        call Order 

      when help_i
        help_command 
        
      when exit_i
        reply exit_o
        exit

      else
        reply what_o
        help_command
      end  
    end    

    private
    #
    # state: help_command
    #
    def help_command(text=nil)
      # some explanation
      reply help_command_o        

      # back to the same state
      go :command, command_o
    end

  end  
end

