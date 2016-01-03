#
# list.rb
#
module Dialogs 
  #
  # List dialog
  # collect an item list 
  #
  class List < Dialog

    def self.initialize_data
      []
    end  

    #
    # state: start
    #
    def start(text)
      go :add, add_o 
    end

    #
    # state: add
    #
    def add(item)
      case item
      when yes_i 
        go :add, add_more_o

      when no_i || exit_i 
        if data.empty?
          reply aborted_o 
          return back :finish
        end  

        # list items
        reply_list
        go :confirm, confirm_o 

      when help_i  
        help_add
      
      when list_i 
        reply_list
        go :add, add_more_o

      else
        #
        # NLP understanding
        #
        interpret item

        # add line to data text
        data.push item

        # back to the same state
        go :add, add_more_o 
      end  
    end    


    #
    # state: del
    #
    def del(choice)
      index = choice.to_i - 1
      case index
      # valid index
      when 0..data.size 
        data.delete_at index
        reply_list
        go :confirm, confirm_o
      else
        # invalid choice
        reply_list
        go :del, del_invalid_choice_o
      end  
    end  


    #
    # state: confirm
    #
    def confirm(choice)
      case choice

      when yes_i
        # items list data confirmed
        reply confirmed_o 
        reply_list
        save data 
        back :finish

      when no_i
        help_confirm

      when exit_i
        # data have to be deleted ?
        self.data = nil
        reply aborted_o 
        back
      
      when add_i 
        go :add, add_more_o 
      
      when del_i 
        go :del, del_o(data.size)

      when help_i
        help_confirm

      else
        help_confirm
        go :confirm, confirm_o 
      end
    end    


    #
    # item interpretation 
    # need real language processing
    # real logic to be implemented in subclass
    #
    def interpret(item)
      #
      # accept everything:
      # no statement interpretation here, just ok
      reply valid_item_o
    end  

    def finish(value)
      back
    end  


    private

    #
    # list items
    #
    def reply_list
      reply "#{data.size} items:"
      data.each_with_index do | line, i | 
        reply "[#{i+1}] #{line}"
      end
    end


    #
    # state: help_add
    #
    def help_add
      # some explanation
      reply help_add_o  
        
      # back to the same state
      go :add, add_more_o
    end

    #
    # state: help_confirm
    #
    def help_confirm
      reply help_confirm_o 
      
      # back to the same state
      go :confirm
    end

  end  
end

