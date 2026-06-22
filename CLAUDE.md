# efacturapty

Ruby gem for Panama's DGI electronic invoicing (e-factura) API.

## Structure

```
lib/
  efacturapty.rb          # top-level require, Efacturapty::Error
  efacturapty/
    version.rb            # VERSION constant
spec/
  spec_helper.rb
  efacturapty_spec.rb
efacturapty.gemspec
```

## Commands

```sh
bundle exec rspec         # run tests
bundle exec rubocop       # lint
gem build efacturapty.gemspec  # build .gem file
```

## Conventions

- Ruby >= 3.1
- RSpec for tests, RuboCop for linting
- All public API classes live under `lib/efacturapty/`
- Keep `Efacturapty::Error` as the base error class; subclass it for domain errors
- Semantic versioning; update `CHANGELOG.md` and `version.rb` together on each release
