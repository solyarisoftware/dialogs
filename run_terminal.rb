#!/usr/bin/env ruby

require 'awesome_print'
require 'colorize'

require_relative 'lib/dialog'
require_relative 'lib/session'
require_relative 'lib/adapters/stdio'


def trap_ctrlc
  trap('INT') do
    # Marshal.dump @notified_orders_set
    #File.open(@notified_orders_filename,'w') { |file| Marshal.dump(@notified_orders_set, file) }

    puts
    puts Session.load.to_s.yellow
    puts
    puts "#{$0} has ended (crowd applauds)"
    exit 0
  end

end


#
# require all necessary dialogs
#
Dialog.require :command
Dialog.require :order
Dialog.require :list

#
# initial default session (start from main dialog)
#
Dialog.root Command

#
# CTRl-C to exit the loop 
#
trap_ctrlc

#
# start Dialog as a terminal chat
#
Dialog.run ClientAdapter::Terminal
