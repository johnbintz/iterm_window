# iTermWindow

*Make iTerm obey your command! Start up your complex development environment quickly and easily.*

The typical Rails project requires three or tour terminal windows/tabs open at once:

* The Rails app itself running using `rails s`
* Two continuous testing environments, powered by Guard or Autotest, running on your Ruby and JavaScript code
* A console ready for committing code or other maintenance tasks
* A log file or two

Opening all the necessary terminals, starting the right processes in each, and making them easily identifiable
is a long, slow process when done by hand. But guess what -- computers can be used to automate processes that
otherwise would be laborious when done manually!

Enter *iTermWindow*, a terminal window/tab multiplexer and command runner for Mac OS X and iTerm, the really
awesome Terminal.app replacement. iTerm's scriptability and customization allows one to create complex
project configurations for one's terminal setups.

## Installation

`gem install itermwindow` or add it to your Gemfile.

## Usage

The `iterm-window` executable will open and run an `iTermfile` file in the current directory. 
An `iTermfile` file looks like this:

``` ruby
open :dir => Dir.pwd do
  default_tab :console

  open_tab :rails, :color => :rails do
    rails "s"
  end

  open_tab :rspec, :color => :rspec do
    guard "-g rspec"
  end

  open_tab :log, :color => "DDB" do
    tail "+F -fr log/sphinx.log"
  end
end
```

In a nutshell:

* `open` blocks open new iTerm windows.
* `current` blocks use the cirrent iTerm window.
  * Inside `open` or `current` blocks you can open a new tab with `open_tab`.
  * Specify a tab to be the selected tab with `default_tab`.
    * Inside of a tab, you can write text into the terminal with `write_text`.
    * Set the title of the tab with `set_title`.
    * Or run a command magically (using `method_missing`).

`open_tab` and `default_tab` can take an options hash:

* `:dir` changes to the given directory before executing commands.
* `:color` changes the window chrome and tab color to the given hex code (3 or 6 hex digits) or built-in color. See ItermWindow.colors for the list of available colors.

`open` can also take an options hash:

* `:dir` changes all tabs to the given directory before executing commands.

More docs coming soon! Also, look at `lib/iterm_window.rb` for more usage examples.

* Developed March 17, 2008 by Chris Powers
* Extended June 2011 and beyond by John Bintz and (hopefully) many others

