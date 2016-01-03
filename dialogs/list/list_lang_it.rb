#
# list_text_it.rb
#
module Dialogs 
  class List < Dialog
    private
    #
    # input
    #
    def exit_i
      /\bexit\b|\besci\b/i
    end

    def no_i
      /
        \bno\b 
      | 
        \bniente\b 
      |
        \bbasta\b 
      |
        \bstop\b
      |
        \bfine\b
      /ix
    end

    def help_i
      /\bhelp\b|\baiuto\b|^\?/i
    end

    def list_i
      /\blista\b/i
    end  

    def yes_i
      /\bsi\b|\bok\b|\bprocedi\b|\bvai\b/i
    end  

    def del_i
      /\bdel\b|\btogli\b|\brimuovi\b/i
    end  

    def add_i
      /\badd\b/i
    end  

    #
    # output
    #
    def add_o
      [
        'cosa vuoi mettere in lista?',
        'cosa desideri?'
      ].sample
    end

    def add_more_o
      [
        "cosa aggiungi?", 
        "vuoi altro?", 
        "dopo?", 
        "nient'altro?", 
        "cos'altro?",
        "altro?"
      ].sample   
    end
    

    def aborted_o
      'operazione annullata'
    end

    def confirm_o
      "confermi lista ?"
    end

    def confirmed_o
      "lista confermata!"
    end

    def del_o(max_num)
      [
        "quale item vuoi cancellare (1-#{max_num}) ?", 
        "cosa vuoi togliere (1-#{max_num}) ?"
      ].sample
    end
    
    def del_invalid_choice_o
      "numero non valido\n" \
      "quale item vuoi cancellare ?"  
    end  
    
    def help_add_o 
      "opzioni:\n" \
      "[no] per uscire\n" \
      "[lista] elenca items\n" \
      "Aggiungi altro item a lista\n"
    end 
    
    def help_confirm_o 
      "opzioni:\n" \
      "[ok] per confermare.\n" \
      "[add] per aggiungere\n" \
      "[del] per rimuove item\n" \
      "[exit] per annullare operazione\n"
    end 
    
    def valid_item_o
     [ 
       "ok",
       "item inserito",
       "perfetto",
       "bene",
       "si"
     ].sample  
    end
  end  
end

