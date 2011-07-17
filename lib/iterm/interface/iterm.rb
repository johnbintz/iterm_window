module Iterm
  module Interface
    class Iterm
      attr_reader :buffer, :window

      class << self
        def create_tab_color(color)
          raise ArgumentError.new("bad hex color: #{color}") if color.downcase[%r{[^a-f0-9]}] || !([ 3, 6 ].include?(color.length))
          %w{red green blue}.zip(color.scan(
            (case color.length
        when 3
          /./
        when 6
          /../
        end)
          ).collect { |part|
            part += part if part.length == 1
            part.hex
          }).collect do |color, brightness|
            "\033]6;1;bg;#{color};brightness;#{brightness}\a"
          end.join
        end
      end

      def initialize(window)
        @window = window
        @buffer = []
      end

      def <<(command)
        @buffer << command.gsub("'", '"').gsub('\\', '\\\\\\')
      end

      def execute(window_type, &block)
        window_types = {:new => '(make new terminal)', :current => 'first terminal'}
        raise ArgumentError, "Iterm::Window#run_commands should be passed :new or :current." unless window_types.keys.include? window_type
        self << "tell application 'iTerm'"
        self << "activate"
        self << "set myterm to #{window_types[window_type]}"
        self << "tell myterm"

        window.instance_eval(&block) if block_given?

        self << "end tell"
        self << "end tell"
      end

      def concatenated_buffer
        @buffer.join("\n")
      end

      def new_session(name, bookmark = nil)
        self << "launch session '#{bookmark}'"
        self << "set #{name}_tty to the tty of the last session"
      end

      def cd(dir)
        self << write("cd #{dir}")
      end

      def chrome_color(color)
        self << write("cat #{file = create_tab_color_file(color)} && rm #{file}")
      end

      private
      def write(text)
        %{write text "#{text}"}
      end

      def create_tab_color_file(color)
        file = Tempfile.open('iterm').path + '.tc'
        File.open(file, 'wb') { |f| f.puts self.class.create_tab_color(ensure_color(color)) }
        @window.tab_color_files << file
        file
      end

      def ensure_color(color)
        case color
        when Symbol
          Iterm::Window.colors[color]
        else
          color
        end
      end
    end
  end
end

