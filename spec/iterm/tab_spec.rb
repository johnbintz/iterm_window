require 'spec_helper'
require 'iterm/tab'
require 'iterm/window'

describe Iterm::Tab do
  before(:each) do
    @window = Iterm::Window.new
    Kernel.stubs(:system)
  end

  describe '#tab_color' do
    it 'should generate color in a tab definition' do
      @window.expects(:shell_out)
      @window.interface.expects(:chrome_color).with("FF00AA")

      @window.run do
        open_tab :first_tab, :color => "FF00AA" do
        end
      end
    end

    it 'should use predetermined colors' do
      @window.expects(:shell_out)
      @window.interface.expects(:chrome_color).with(:rails)

      @window.run do
        open_tab :first_tab, :color => :rails do
        end
      end
    end
  end
end
