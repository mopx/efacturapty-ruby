require "rails/railtie"

module Efacturapty
  # Rails integration: loads generators automatically when Rails is present.
  class Railtie < Rails::Railtie
    generators do
      require "generators/efacturapty/install_generator"
    end
  end
end
