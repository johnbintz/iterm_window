require 'tempfile'
require 'iterm/tab'
require 'iterm/interface/iterm'
require 'forwardable'

module Iterm
  class Window
    extend Forwardable

    attr_reader :tab_color_files, :interface

    def_delegators :interface, :concatenated_buffer

    class << self
      def colors=(colors)
        @colors = colors
      end

      def colors
        @colors
      end

      def add_command(name, &block)
        Iterm::Tab.send(:define_method, name, block)
      end

      def run_file(file)
        instance_eval(file)
      end

      # Creates a new terminal window, runs the block on it
      def open(options = {}, &block)
        new.run(:new, options, &block)
      end

      # Selects the first terminal window, runs the block on it
      def current(&block)
        new.run(:current, &block)
      end
    end

    Window.colors = {
      :rails => 'F99',
      :rspec => '99F',
      :js => '9F9',
      :doc => 'FF9',
      :log => 'DFF',
    }

    # While you can directly use ItermWindow.new, using either ItermWindow.open or
    # ItermWindow.current is the preferred method.
    def initialize
      @buffer = []
      @tabs = {}
      @tab_color_files = []
      @default_tab = nil

      @interface = Iterm::Interface::Iterm.new(self)
    end

    def run(window_type = :new, options = {}, &block)
      @options = options
      run_commands window_type, &block
      send_output
    end

    # Creates a new tab from a bookmark, runs the block on it
    def open_bookmark(name, bookmark, &block)
      create_tab(name, bookmark, &block)
    end

    # Creates a new tab from 'Default Session', runs the block on it
    def open_tab(name, options = {}, &block)
      create_tab(name, 'Default Session', options, &block)

      @default_tab = name if options[:default]
    end

    def default_tab(name, options = {}, &block)
      open_tab(name, options.merge(:default => true), &block)
    end

    def output(line)
      @interface << line
    end

    private

    # Outputs @buffer to the command line as an osascript function
    def send_output
      shell_out
    end

    # Initializes the terminal window
    def run_commands(window_type, &block)
      @interface.execute(window_type) do
        instance_eval(&block)
        @tabs[@default_tab].select if @default_tab
      end
    end

    # Creates a new Tab object, either default or from a bookmark,
    # and creates a convenience method for retrieval
    def create_tab(name, bookmark=nil, options = {}, &block)
      @tabs[name] = Tab.new(self, name, bookmark, @options.merge(options), &block)
      create_tab_convenience_method(name)
    end

    def create_tab_convenience_method(name)
      (class << self; self; end).send(:define_method, name) do
        @tabs[name]
      end
    end

    def shell_out
      Tempfile.open('iterm') do |f|
        f.print concatenated_buffer
        f.close
        system %{osascript #{f.path}}
      end
    end
  end
end
