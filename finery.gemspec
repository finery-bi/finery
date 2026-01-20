require_relative "lib/blazer/version"

Gem::Specification.new do |spec|
  spec.name          = "finery"
  spec.version       = Blazer::VERSION
  spec.summary       = "Explore your data with SQL. Easily create charts and dashboards, and share them with your team. A drop-in replacement for Blazer."
  spec.homepage      = "https://github.com/finery-bi/finery"
  spec.license       = "MIT"

  spec.author        = "Andrew Kane, Chris Hasinski, Tomasz Ratajczak and contributors"
  spec.email         = "krzysztof.hasinski+finery@gmail.com"

  spec.files         = Dir["*.{md,txt}", "{app,config,lib,licenses}/**/*"]
  spec.require_path  = "lib"

  spec.required_ruby_version = ">= 3"

  spec.add_dependency "railties", ">= 6.1"
  spec.add_dependency "activerecord", ">= 6.1"
  spec.add_dependency "csv"
  spec.add_dependency "logger"
  spec.add_dependency "safely_block", ">= 0.4"
  spec.add_dependency "stimulus-rails", "~> 1.2"

  # Optional: AI features (natural language to SQL, query explanation, etc.)
  spec.add_dependency "ruby_llm", ">= 1.0"
end
