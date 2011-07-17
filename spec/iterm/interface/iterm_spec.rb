require 'spec_helper'
require 'iterm/interface/iterm'

describe Iterm::Interface::Iterm do
  let(:iterm) { described_class.new(self) }

  describe "#execute" do
    it 'should create a new terminal' do
      iterm.execute(:new) do
      end

      iterm.concatenated_buffer.should == (<<-TXT).strip
tell application "iTerm"
activate
set myterm to (make new terminal)
tell myterm
end tell
end tell
      TXT
    end

    it 'should use the current terminal' do
      iterm.execute(:current) do
      end

      iterm.concatenated_buffer.should == (<<-TXT).strip
tell application "iTerm"
activate
set myterm to first terminal
tell myterm
end tell
end tell
      TXT
    end
  end

  describe '#<<' do
    it 'should add a line of output to the buffer' do
      iterm << "my 'command'"
      iterm.buffer.should == [ %{my "command"} ]
    end
  end

  describe '#new_session' do
    it 'should start a new session' do
      iterm.new_session('one', 'two')

      iterm.concatenated_buffer.should =~ /one/
        iterm.concatenated_buffer.should =~ /two/
    end
  end

  describe '#cd' do
    it 'should write the command to cd to a directory' do
      iterm.cd('/here/there')

      iterm.concatenated_buffer.should == %{write text "cd /here/there"}
    end
  end

  describe '#chrome_color' do
    it "should generate and run the correct Applescript" do
      iterm.expects(:create_tab_color_file).with("FF00AA")
      iterm.chrome_color("FF00AA")

      iterm.concatenated_buffer.should =~ /cat /
    end
  end

  describe ".create_tab_color" do
    subject { described_class.create_tab_color(color) }

    context 'bad hex color' do
      [ "whatever", "F00F" ].each do |bad|
        context bad do
          let(:color) { bad }

          it 'should raise an exception on bad hex color' do
            expect { subject }.to raise_error(ArgumentError, /bad hex color/)
          end
        end
      end
    end

    context 'long hex color' do
      let(:color) { "FF00AA" }

      it 'should create an escape sequence to execute to change a tab color' do
        subject.should match(/red;brightness;255/)
        subject.should match(/green;brightness;0/)
        subject.should match(/blue;brightness;170/)
      end
    end

    context 'short hex color' do
      let(:color) { "F0A" }

      it 'should create an escape sequence to execute to change a tab color' do
        subject.should match(/red;brightness;255/)
        subject.should match(/green;brightness;0/)
        subject.should match(/blue;brightness;170/)
      end
    end
  end
end

