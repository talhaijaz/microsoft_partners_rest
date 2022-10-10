$:.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'microsoft_partners_rest_api/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'microsoft_partners_rest'
  s.version     = MicrosoftPartnersRestApi::VERSION
  s.authors     = ['Talha Ijaz']
  s.email       = ['talhaijaz123451@gmail.com']
  s.homepage    = 'https://github.com/talhaijaz/microsoft_partners_rest'
  s.summary     = 'Microsoft Partners API wrapper'
  # s.description = 'Abstracted Autotask API 1.5 wrapper'

  s.files = Dir['{app,config,db,lib}/**/*', 'Rakefile', 'README.md']

  s.add_dependency 'rest-client'
end
