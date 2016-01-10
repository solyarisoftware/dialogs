#
# ask_lang_it.rb
#
module Dialogs 
  class Ask < Dialog
    private
    #
    # input
    #
    def help_i
      /\bhelp\b|\baiuto\b|^\?/i
    end

    #
    # output
    #
    def ask_o
      [
        'domanda?'
      ].sample
    end

    def help_ask_o 
      "inserire una domanda" 
    end 

    # to be implemented in a dialog subclass 
    def answer_o(answer)
      "risposta: ok"
    end
  end  
end

