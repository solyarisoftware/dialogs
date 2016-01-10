#!/usr/bin/env ruby

require 'awesome_print'
require 'colorize'

require_relative 'engine/dialog'
require_relative 'engine/session'
require_relative 'engine/adapters/stdio'


def trap_ctrlc
  trap('INT') do
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
Dialog.require :ask

#
# initial default session (start from main dialog)
#
Dialog.root Command #Ask

#
# CTRl-C to exit the loop 
#
trap_ctrlc

#
# start Dialog as a terminal chat
#
Dialog.run ClientAdapter::Terminal

