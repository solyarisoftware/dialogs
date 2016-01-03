require 'rake'
require 'awesome_print'
require 'colorize'

require_relative 'lib/dialog'
require_relative 'lib/session'
require_relative 'lib/adapters/stdio'

# http://stackoverflow.com/a/11320444/1786393
Rake::TaskManager.record_task_metadata = true

# http://stackoverflow.com/a/11320444/1786393
task :default do
  Rake::application.options.show_tasks = :tasks  # this solves sidewaysmilk problem
  Rake::application.options.show_task_pattern = //
  Rake::application.display_tasks_and_comments
end

=begin
namespace :telegram do
  desc "Create bot app template for given token"
  task :new, [:token] do |t, args|
    bot_name = Tokens.find_bot_name(args.token)
    Template.build_app(bot_name, args.token, Config.app_directory)
  end
end
=end

namespace :run do
  desc "run dialog from terminal"
  task :terminal do
    run_terminal 
  end

  desc "run dialog as telegram bot"
  task :telegram do
    # TODO
  end
end


def run_terminal
  #
  # require all necessary dialogs
  #
  Dialog.require :main
  Dialog.require :order
  Dialog.require :list

  #
  # initial default session (start from main dialog)
  #
  Dialog.root Main

  #
  # CTRl-C to exit the loop 
  #
  trap_ctrlc

  #
  # start Dialog as a terminal chat
  #
  Dialog.run ClientAdapter::Terminal
end

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

# aliases 
#task :server => 'server:show'
