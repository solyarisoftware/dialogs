#
# main.rb
#
module Dialogs 
  #
  # List available dialogs/commands
  #
  class Command < Dialog
    
    private
    #
    # input 
    #
    def order_i
      /\bordine\b/i 
    end
    
    def help_i
      /\bhelp\b|\baiuto\b|^\?/i
    end

    def exit_i
      /\bquit\b|\besc\b|\bexit\b/i
    end

    #
    # output 
    #
    def help_command_o
      "comandi:\n" \
      "[ordine]\n" \
      "[quit]\n"
    end

    def command_o
      'comando ?'
    end  

    def what_o
      "non ho capito"
    end

    def exit_o
      "dialogo terminato dall'utente."
    end  
  end  
end

