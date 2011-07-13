Gem::Specification.new do |s|
  s.name = 'itermwindow'
  s.version = '0.4.1'
  s.authors = [ 'Chris Powers', 'John Bintz' ]
  s.date = Time.now
  s.homepage = 'http://github.com/johnbintz/iterm_window'
  s.email = [ 'chrisjpowers@gmail.com', 'john@coswellproductions.com' ]
  s.summary = 'Easily start up new windows and tabs for your projects in iTerm.'
  s.files = ['README.md', 'LICENSE', 'CHANGELOG.md', 'lib/iterm_window.rb']
  s.require_paths = ["lib"]
  s.has_rdoc = true
  s.executables << "iterm-window"

  s.add_development_dependency 'rspec', '~> 2.6.0'
  s.add_development_dependency 'fakefs'
  s.add_development_dependency 'mocha'
end

