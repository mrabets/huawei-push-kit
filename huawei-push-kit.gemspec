Gem::Specification.new do |s|
  s.name        = "huawei-push-kit"
  s.version     = "1.0.1"
  s.summary     = "Huawei Push Kit Client for Ruby"
  s.description = "Huawei Push Kit Client for Ruby"
  s.authors     = ["Karim Marabet"]
  s.email       = "newrabgo@gmail.com"
  s.files       = Dir["LICENSE.txt", "README.md", "lib/**/*.rb"]
  s.require_paths = ["lib"]
  s.license     = "MIT"
  s.homepage    = "https://github.com/mrabets/huawei-push-kit"

  s.add_dependency "faraday", "~> 1.0"
  s.add_dependency "json"

  s.add_development_dependency "bundler", "~> 2.0"
  s.add_development_dependency "rake", "~> 13.0"
end
