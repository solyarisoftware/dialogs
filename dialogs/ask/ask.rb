#
# ask.rb
#
module Dialogs 
  #
  # List dialog
  # collect an item list 
  #
  class Ask < Dialog

    def self.initialize_data
      '' # void string
    end  

    # state: start
    def start(text)
      go :ask, ask_o 
    end

    #
    # state: ask
    #
    def ask(question)
      case question
      when help_i  
        help_ask

      else  
        # NLP understanding
        answer = interpret question

        # add line to data text
        self.data = answer

        back :finish
      end
    end

    # state: finish
    def finish(value)
      back
    end    

    private

    #
    # item interpretation 
    # need real language processing
    # real logic to be implemented in subclass
    #
    def interpret(question)
      #
      # accept everything:
      # no statement interpretation here, just ok
      #
      answer = nil

      reply answer_o(answer)
    end  


    #
    # state: help_add
    #
    def help_ask
      # some explanation
      reply help_ask_o  
        
      # back to the same state
      go :ask, ask_o
    end

  end  
end

