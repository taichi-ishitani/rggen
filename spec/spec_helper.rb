if ENV['COVERAGE']
  require 'simplecov'
  SimpleCov.start

  if ENV['CODECOV_TOKEN']
    require 'codecov'
    SimpleCov.formatter = SimpleCov::Formatter::Codecov
  end
end

Encoding.default_external = Encoding::UTF_8

require_relative '../lib/rggen'

require_relative  'support/helper_methods'
require_relative  'support/matchers'
require_relative  'support/config'
