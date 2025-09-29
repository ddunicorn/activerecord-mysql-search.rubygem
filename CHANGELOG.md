## [Unreleased]

- Adds automatic loading of source classes on Rails startup via new `autoload_sources` configuration option (default: true)
- Adds `load_source_classes!` alias method for manually loading source classes

## [0.2.0] - 2025-09-25

- Removes text normalization from default `:text` formatter
- Search term passed as argument to the scope `.full_text_search` is not pre-normalized anymore
- Adds `register_format` method to register custom formatters

## [0.1.3] - 2025-08-06

- Move rake tasks to the proper place + explicit tasks load

## [0.1.2] - 2025-08-12

- Removes code of conduct

## [0.1.1] - 2025-08-05

- Fixes load paths to rake tasks

## [0.1.0] - 2025-07-22

- Initial release
