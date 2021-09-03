
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "libis/metadata/version"

# noinspection RubyResolve
Gem::Specification.new do |spec|
  spec.name          = "libis-metadata"
  spec.version       = Libis::Metadata::VERSION
  spec.authors       = ["Kris Dekeyser"]
  spec.email         = ["kris.dekeyser@libis.be"]

  spec.summary       = %q{All about metadata.}
  spec.description   = %q{A gem with every generic ruby tool and class related to metadata.}
  spec.homepage      = "https://github.com/Kris-Libis/LIBIS_Metadata"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject {|f| f.match(%r{^(test|spec|features)/})}
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'libis-tools', '~> 1.0'
  spec.add_runtime_dependency 'libis-services', '~> 1.0'
  spec.add_runtime_dependency 'simple_xlsx_reader', '~> 1.0'
  spec.add_runtime_dependency 'parslet', '~> 1.7'
  spec.add_runtime_dependency 'tty-prompt'
  spec.add_runtime_dependency 'thor'

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'simplecov', '~> 0.9'
  spec.add_development_dependency 'coveralls', '~> 0.7'
  spec.add_development_dependency 'equivalent-xml', '~> 0.5'
  spec.add_development_dependency 'awesome_print', '~> 1.6'

end
