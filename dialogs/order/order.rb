#
# order.rb
#
module Dialogs 
  #
  # TODO
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
    end

    #
    # state: finish
    #
    def finish(value)
      back
    end    


  end  
end

