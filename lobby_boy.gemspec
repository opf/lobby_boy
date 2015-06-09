$:.push File.expand_path("../lib", __FILE__)

require "lobby_boy/version"

Gem::Specification.new do |s|
  s.name        = "lobby_boy"
  s.version     = LobbyBoy::VERSION
  s.authors     = ["Finn GmbH"]
  s.email       = ["info@finn.de"]
  s.homepage    = "https://github.com/finnlabs/lobby_boy"
  s.summary     = "Rails engine for OpenIDConnect Session Management"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency 'rails', '>= 3.2.21'
  s.add_dependency 'jquery-rails'
  s.add_dependency 'rack-cors', '~> 0.4.0'

  s.add_dependency 'omniauth', '~> 1.1'
  s.add_dependency 'omniauth-openid-connect', '>= 0.2'

  s.add_development_dependency 'sqlite3'
end
