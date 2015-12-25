# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rgen/version'

Gem::Specification.new do |spec|
  spec.name                   = "rgen"
  spec.version                = RGen::VERSION
  spec.required_ruby_version  = ">= 2.0"
  spec.authors                = ["Taichi Ishitani"]
  spec.email                  = ["taichi730@jf6.so-net.ne.jp"]

  spec.summary        = "Code generation tool for control registers in a SoC design."
  spec.description    = <<-EOS
    RGen is a code generation tool for SoC designers.
    You can automatically generate soruce code for control registers in a SoC design, e.g. RTL, UVM RAL model, from its register map document.
    You can also customize RGen, so you can build your specific generation tool.
  EOS
  spec.homepage       = ""
  spec.license        = "MIT"

  spec.files          = `git ls-files -z`.split("\x0").reject { |f|
    f =~ %r{^(?:
      bin/setup
      |spec/.*
      |Gemfile
      |Rakefile
      |.gitignore
      |.rspec
      |.travis.yml
    )$}x
  }
  spec.bindir         = "bin"
  spec.executables    = ["rgen"]
  spec.require_paths  = ["lib"]

  spec.add_runtime_dependency "baby_erubis", ">= 2.0"
  spec.add_runtime_dependency "facets"     , ">= 3.0"
  spec.add_runtime_dependency "roo"        , ">= 2.1.1"
  spec.add_runtime_dependency "spreadsheet", ">= 1.0.3"

  spec.add_development_dependency "rake"   , "~> 10.0"
  spec.add_development_dependency "rspec"  , ">=  3.3"
  spec.add_development_dependency "rubocop", ">=  0.35"
end
