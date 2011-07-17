require 'spec_helper'
require 'iterm/window'

describe Iterm::Window do
  before(:each) do
    @window = Iterm::Window.new
    Kernel.stubs(:system)
  end
  
  describe ".current" do
    it "should instantiate the current window and run the block" do
      Iterm::Window.expects(:new).returns(@window)
      @window.expects(:run).with(:current)
      Iterm::Window.current do
        
      end
    end
  end
  
  describe ".open" do
    it "should instantiate a new window and run the block" do
      Iterm::Window.expects(:new).returns(@window)
      @window.expects(:run).with(:new, {})
      Iterm::Window.open do
        
      end
    end
  end
  
  describe '.run_file' do
    it "should read the file and create a window" do
      Iterm::Window.expects(:new).returns(@window)
      @window.expects(:run).with(:new, {})
      Iterm::Window.run_file(<<-FILE)
open do
  open_tab :test
end
FILE
    end
  end

  describe '.add_command' do
    before do
      Iterm::Tab.send(:remove_method, :test) rescue nil
    end

    it 'should define a method on the Tab class' do
      Iterm::Window.add_command :test do |params|
        params
      end

      Iterm::Tab.should have_a_method_named(:test, 1)
    end

    after do
      Iterm::Tab.send(:remove_method, :test) rescue nil
    end
  end

  describe "opening a tab (example 1)" do
    before(:each) do
      Iterm::Window.expects(:new).returns(@window)
    end
    
    it "should generate and run the right Applescript" do
      desired = (<<-CMD).strip
tell application "iTerm"
activate
set myterm to (make new terminal)
tell myterm
launch session "Default Session"
set my_tab_tty to the tty of the last session
tell session id my_tab_tty
write text \"cd ~/projects/my_project/trunk\"
write text \"mate ./\"
end tell
end tell
end tell
CMD
      @window.expects(:shell_out)
      
      Iterm::Window.open do
        open_tab :my_tab do
          write "cd ~/projects/my_project/trunk"
          write "mate ./"
        end
      end

      @window.concatenated_buffer.should == desired
    end
  end
  
  describe "open multiple tabs (example 2)" do
    before(:each) do
      Iterm::Window.expects(:new).returns(@window)
    end
    
    it "should generate and run the right Applescript" do
      desired = (<<-CMD).strip
tell application "iTerm"
activate
set myterm to first terminal
tell myterm
launch session "Default Session"
set project_dir_tty to the tty of the last session
tell session id project_dir_tty
write text "cd ~/projects/my_project/trunk"
write text "mate ./"
set name to "MyProject Dir"
end tell
launch session "Default Session"
set server_tty to the tty of the last session
tell session id server_tty
write text "cd ~/projects/my_project/trunk"
write text "script/server -p 3005"
set name to "MyProject Server"
end tell
launch session "Default Session"
set console_tty to the tty of the last session
tell session id console_tty
write text "cd ~/projects/my_project/trunk"
write text "script/console"
set name to "MyProject Console"
end tell
end tell
end tell
CMD
      @window.expects(:shell_out)
      
      Iterm::Window.current do
        open_tab :project_dir do
          write "cd ~/projects/my_project/trunk"
          write "mate ./"
          set_title "MyProject Dir"
        end
    
        open_tab :server do
          write "cd ~/projects/my_project/trunk"
          write "script/server -p 3005"
          set_title "MyProject Server"
        end
        
        open_tab :console do
          write "cd ~/projects/my_project/trunk"
          write "script/console"
          set_title "MyProject Console"
        end
      end

      @window.concatenated_buffer.should == desired
    end
  end
  
  describe "open tabs using bookmarks (example 3)" do
    before(:each) do
      Iterm::Window.expects(:new).returns(@window)
    end
    
    it "should generate and run the correct Applescript" do
      desired = (<<-CMD).strip
tell application "iTerm"
activate
set myterm to first terminal
tell myterm
launch session "Default Session"
set project_dir_tty to the tty of the last session
tell session id project_dir_tty
write text "cd ~/projects/my_project/trunk"
write text "mate ./"
end tell
launch session "MyProject Server"
set server_tty to the tty of the last session
launch session "MyProject Console"
set console_tty to the tty of the last session
select session id project_dir_tty
end tell
end tell
CMD
      @window.stubs(:shell_out)
      
      Iterm::Window.current do
        open_tab :project_dir do
          write "cd ~/projects/my_project/trunk"
          write "mate ./"
        end
    
        open_bookmark :server, 'MyProject Server'
        open_bookmark :console, 'MyProject Console'
    
        project_dir.select
      end

      @window.concatenated_buffer.should == desired
    end
  end

  describe "switching between tabs (example 4)" do
    before(:each) do
      Iterm::Window.expects(:new).returns(@window)
    end
    
    it "should generate and run the correct Applescript" do
      desired = (<<-CMD).strip
tell application "iTerm"
activate
set myterm to (make new terminal)
tell myterm
launch session "Default Session"
set first_tab_tty to the tty of the last session
launch session "Default Session"
set second_tab_tty to the tty of the last session
tell session id first_tab_tty
write text "cd ~/projects"
write text "ls"
end tell
tell session id second_tab_tty
write text "echo "hello there!""
end tell
select session id first_tab_tty
end tell
end tell
CMD
      @window.expects(:shell_out)
      
      Iterm::Window.open do
        open_tab :first_tab
        open_tab :second_tab
        first_tab.select do
          write 'cd ~/projects'
          write 'ls'
        end
        second_tab.write "echo 'hello there!'"
        first_tab.select
      end

      @window.concatenated_buffer.should == desired
    end
  end

  describe 'magic commands' do
    before(:each) do
      Iterm::Window.expects(:new).returns(@window)
    end
    
    it "should cd to the directory for the tab" do
      @window.expects(:shell_out)
      
      Iterm::Window.open do
        open_tab :first_tab do
          bundle "exec guard"
        end
      end

      @window.concatenated_buffer.should match(/write text "bundle exec guard"/)
    end
  end

  describe 'default tab' do
    before(:each) do
      Iterm::Window.expects(:new).returns(@window)
    end
    
    it "should mark the tab as the default tab" do
      @window.expects(:shell_out)
      
      Iterm::Window.open do
        open_tab :first_tab, :default => true do
        end
      end

      @window.concatenated_buffer.should match(/select session id first_tab_tty/)
    end

    it "should mark the tab as the default tab" do
      @window.expects(:shell_out)
      
      Iterm::Window.open do
        default_tab :first_tab do
        end
      end

      @window.concatenated_buffer.should match(/select session id first_tab_tty/)
    end
  end

  describe 'change directory' do
    before(:each) do
      Iterm::Window.expects(:new).returns(@window)
    end
    
    it "should cd to the directory for the tab" do
      @window.expects(:shell_out)
      
      Iterm::Window.open do
        open_tab :first_tab, :dir => 'my-dir' do
        end
      end

      @window.concatenated_buffer.should match(/cd my-dir/)
    end

    it "should cd to the directry for all tabs" do
      @window.expects(:shell_out)
      
      Iterm::Window.open :dir => 'my-dir' do
        open_tab :first_tab do
        end
      end

      @window.concatenated_buffer.should match(/cd my-dir/)
    end
  end
end
