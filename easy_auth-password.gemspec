$:.push File.expand_path('../lib', __FILE__)

require 'easy_auth/password/version'

Gem::Specification.new do |s|
  s.name        = 'easy_auth-password'
  s.version     = EasyAuth::Password::VERSION
  s.authors     = ['Brian Cardarella']
  s.email       = ['brian@dockyard.com', 'bcardarella@gmail.com']
  s.homepage    = 'https://github.com/dockyard/easy_auth-password'
  s.summary     = 'EasyAuth-Password'
  s.description = 'EasyAuth-Password'

  s.files = Dir['{app,config,db,lib}/**/*'] + ['Rakefile', 'README.md']

  s.add_dependency 'easy_auth', '~> 0.3.0'
  s.add_dependency 'scrypt'

  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'rspec-rails', '~> 2.11.4'
  s.add_development_dependency 'capybara', '~> 2.1'
  s.add_development_dependency 'capybara-email', '~> 2.1.2'
  s.add_development_dependency 'database_cleaner'
  s.add_development_dependency 'valid_attribute'
  s.add_development_dependency 'factory_girl_rails', '~> 1.7.0'
  s.add_development_dependency 'factory_girl', '~> 2.6.0'
  s.add_development_dependency 'mocha', '~> 0.10.5'
  s.add_development_dependency 'launchy'
end
