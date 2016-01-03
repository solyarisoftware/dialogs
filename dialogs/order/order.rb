#
# list.rb
#
module Dialogs 
  #
  # List dialog
  # collect an item list 
  #
  class Order < Dialog

    def self.initialize_data
      nil
    end  

    #
    # state: start
    #
    def start(text)
      call List
      #go :order
    end

    #
    # state: order
    #
    def finish(value)
      back
    end    


  end  
end

