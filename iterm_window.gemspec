Gem::Specification.new do |s|
  s.name = 'johnbintz-iterm_window'
  s.version = '0.4.0'
  s.authors = [ 'Chris Powers', 'John Bintz' ]
  s.date = Time.now
  s.homepage = 'http://github.com/johnbintz/iterm_window'
  s.email = [ 'chrisjpowers@gmail.com', 'john@coswellproductions.com' ]
  s.summary = 'The ItermWindow class models an iTerm terminal window and allows for full control via Ruby commands.'
  s.files = ['README.rdoc', 'LICENSE', 'lib/iterm_window.rb']
  s.require_paths = ["lib"]
  s.has_rdoc = true

  s.add_development_dependency 'rspec', '~> 2.6.0'
  s.add_development_dependency 'fakefs'
  s.add_development_dependency 'mocha'
end

