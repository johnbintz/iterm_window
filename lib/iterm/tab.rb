require 'iterm/window'
require 'forwardable'

module Iterm
# The Tab class models a tab (session) in an iTerm terminal window and allows for it to be controlled by Ruby.
class Tab
  extend Forwardable
  attr_reader :name, :bookmark, :window

  def_delegators :window, :interface

  def initialize(window, name, bookmark = nil, options = {}, &block)
    @name, @bookmark, @window = name, bookmark, window

    @currently_executing_block = false

    interface.new_session(@name, @bookmark)
    interface.cd(options[:dir]) if options[:dir]
    interface.chrome_color(options[:color]) if options[:color]

    execute_block &block if block_given?
  end

  # Brings a tab into focus, runs a block on it if passed
  def select(&block)
    if block_given?
      execute_block &block
    else
      output "select session id #{name}_tty"
    end
  end

  # Writes a command into the terminal tab
  def write(command)
    if @currently_executing_block
      output "write text '#{command}'"
    else
      execute_block { write command }
    end
  end

  # Sets the title of the tab (ie the text on the iTerm tab itself)
  def set_title(str)
    if @currently_executing_block
      output "set name to '#{str}'"
    else
      execute_block { set_title = str }
    end
  end

  # Sets the title of the tab (ie the text on the iTerm tab itself)
  def tab_color(color)
    if @currently_executing_block
      interface.chrome_color(color)
    else
      execute_block { tab_color(color) }
    end
  end

  # Runs a block on this tab with proper opening and closing statements
  def execute_block(&block)
    @currently_executing_block = true
    output "tell session id #{name}_tty"
    self.instance_eval(&block)
    output "end tell"
    @currently_executing_block = false
  end

  def method_missing(name, *args)
    write("#{name} #{args.join(' ')}")
  end


private

def output(command)
  @window.output command
end

end
end

