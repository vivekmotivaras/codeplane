require "./lib/codeplane/version"

Gem::Specification.new do |s|
  s.name        = "codeplane"
  s.version     = Codeplane::Version::STRING
  s.authors     = ["Nando Vieira"]
  s.email       = ["fnando.vieira@gmail.com"]
  s.homepage    = "http://github.com/codeplane/codeplane"
  s.summary     = "Client library and CLI to handle Git repositories on Codeplane."
  s.description = s.summary

  s.add_dependency "activesupport"              , ">= 3.0"
  s.add_dependency "json_pure"                  , "~> 1.5.3"
  s.add_dependency "i18n"
  s.add_development_dependency "rspec"          , "~> 2.6"
  s.add_development_dependency "test_notifier"
  s.add_development_dependency "fakeweb"
  s.add_development_dependency "rake"
  s.add_development_dependency "addressable"    , "~> 2.2.6"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
