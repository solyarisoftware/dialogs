#
# dialogs.rb
#
module Dialogs 
  #
  # super class
  #
  # contains a finite state machine to store context ( state and data )
  #
  class Dialog 
    attr_accessor :path
    attr_accessor :state
    attr_accessor :data
    
    ################
    # class methods
    ################

    #
    # take a list of symbols to include dialogs cose and language
    # by example:
    #
    # Dialog.require :order, :list, language: :EN
    # require these files
    #
    # ../dialogs/order.rb
    # ../dialogs/order_lang_en.rb
    # ../dialogs/list.rb
    # ../dialogs/list_lang_en.rb
    #
    def self.require(*names, directory: 'dialogs', language: 'IT')
      language = language.to_s.downcase

      names.each do |name|
        name = name.downcase
        path = "../#{directory}/#{name}/" 
        require_relative "#{path}#{name}.rb"
        require_relative "#{path}#{name}_lang_#{language}.rb"
      end  
    end


    def self.root(dialog_class) 
      #
      # @classes is an hash containing
      # key: class name, value: relative class instance
      # example:
      #
      # {
      #   :'Dialogs::Command' => Dialog::Command:0x00ab66fc012eb1 
      #   :'Dialogs::Order'   => Dialog::Order:0x00867d0dda3aa5 
      #   :'Dialogs::List'    => Dialog::List:0x007f7b02df5eb0
      # }
      #
      @@classes = {}
      self.from Session.new(dialog_class)
      self
    end


    def self.classes
      @@classes
    end 

    #
    # find a dialog by class name, looking in a in-memory hash
    # if not found, return the a new class instance 
    # if found, return the instance object
    #
    def self.from(session)
      dialog_name = session[:path].last

      #
      # retrieve instance class or create one
      #
      instance = @@classes[dialog_name.to_sym] 

      #
      # If key is not found, create a class instance from nested modules, 
      # eg. 'Dialogs::Order::List'
      # 
      # http://pathoverflow.com/questions/5924495/how-do-i-create-a-class-instance-from-a-string-name-in-ruby
      # Kernel.const_get(dialog).new
      instance ||= (dialog_name.split('::').inject(Object) {|o,c| o.const_get c}).new
      
      #
      # initialize instance variables
      #
      instance.path = session[:path]
      instance.state = session[:state]

      #
      # load in memory just the data corresponding to the dialog
      #
      instance.data = session[:data][dialog_name.to_sym]

      instance
    end  


    # 
    #
    #
    def self.load
      self.from Session.load 
    end


    module DefaultClientAdapter
      def self.read
        gets.chomp  
      end

      def self.write(value)
        puts value.to_s.green
      end
    end

    @@adapter = DefaultClientAdapter

    def self.adapter
      @@adapter
    end

    # Modify the adapter to be used for all Satz applications.
    # The adapter object must reply to `load(arg)` and `dump(arg)`.
    def self.adapter=(value)
      @@adapter = value
    end

    def self.run(client_adapter_class)
      # set the adapter
      self.adapter = client_adapter_class
      
      client_adapter_class.create
        
      loop do
        #
        # istantiate dialog loading last session
        #
        dialog = self.load 
        
        text = self.adapter.read unless (dialog.state == :start) 

        dialog.request text
      end
    end


    ###################
    # instance methods
    ###################

    #
    # get asynch update recv
    # get from user a line (single)
    # call the method corresponding to the actual state
    #
    def request(user_data)
      self.method(state).call(user_data) # unless (:end == state)
    end


    #
    # reply to user a text (multiline)
    #
    def reply(value)
      Dialog.adapter.write value
    end  


    # 
    # trigger next state of this dialog
    #
    def go(state, prompt = nil)
      # reply an optional (question) prompt
      reply(prompt) if prompt

      self.state = state
      #puts state.to_s.red
      Session.save_state self 
    end  


    #
    # go to next dialog(s)
    #
    def call(*dialog, afterward_action: nil)
      if afterward_action
        # at the end of dialogs, will be executed  method specified in aftwerward_action 
        self.path.push self.class.name
        self.state = afterward_action 
        self.data = data

        Session.save_state self
      end
      
      dialog.reverse

      dialog.each do | d |
        # add current dialog to dialog path
        self.path.push d.name
        self.state = :start 

        Session.save_data d, d.initialize_data
        Session.save_state self
      end
    end


    #
    # return to previous dialog in path
    #
    def back(state = :start)
      # remove current dialog from dialog path
      self.path.pop
      self.state = state 

      #self.data = nil unless state == :finish

      Session.save_state self

      self.request '' if state == :finish
    end

    #
    # save data of this dialog instance
    #
    def save(data)
      Session.save_data self.class, data
    end  


=begin
    #
    # 
    #
    def interpret(text, *params, &block)
      call block(text, *params) if block_given?
    end
    def interpret(text)
    end

    #
    # long task run
    #
    def run(*params, &block)
      call block(*params) if block_given?
    end
=end

  end
end

include Dialogs
