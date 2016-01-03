#
# session.rb
#
module Dialogs 
  module Session
     
    #
    #
    #
    def self.new(dialog_class) 
      @@session = {:path => [ dialog_class.name ], :state=> :start, :data=> {}, :time=> Time.now.to_i}
    end

    #
    #
    #
    def self.save_state(dialog)
      @@session[:path] = dialog.path
      @@session[:state] = dialog.state 
      
      #puts "data to save: #{data_to_save.to_s}".red 
      
      #@@session[:data][dialog.path.last.to_sym] = dialog.data if data_to_save
      #@@session[:data][dialog.path.last.to_sym] = dialog.data if data_to_save

      # add a timestamp to the stored session
      @@session[:time] = Time.now.to_i 

      @@session
    end

    def self.save_data(dialog, data)
      @@session[:data][dialog.name.to_sym] = data
    end  


    #
    #
    #
    def self.load
      #puts @@session
      @@session
    end

    def self.data
      @@session[:data]
    end

=begin    
    #
    # local data get method
    #
    #
    def self.local_data
      @@session[:data][path.last.to_sym]
    end

    #
    # local data set method
    #
    def self.local_data=(value) 
      @@session[:data][path.last.to_sym] = value
    end
=end    
  end
end

