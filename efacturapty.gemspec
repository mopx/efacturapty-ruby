require_relative "lib/efacturapty/version"

Gem::Specification.new do |spec|
  spec.name          = "efacturapty"
  spec.version       = Efacturapty::VERSION
  spec.authors       = ["Jorge Yau"]
  spec.email         = ["hola@jorgeyau.com"]

  spec.summary       = "Ruby client for Panama's DGI e-invoicing (e-factura) API"
  spec.description   = "Interact with Panama's Dirección General de Ingresos (DGI) electronic invoicing system from Ruby."
  spec.homepage      = "https://github.com/jorgeyau/efacturapty-ruby"
  spec.license       = "MIT"

  spec.required_ruby_version = ">= 3.1"

  spec.metadata["homepage_uri"]    = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"]   = "#{spec.homepage}/blob/main/CHANGELOG.md"

  spec.files = Dir[
    "lib/**/*",
    "LICENSE",
    "README.md",
    "CHANGELOG.md"
  ]

  spec.require_paths = ["lib"]
end
