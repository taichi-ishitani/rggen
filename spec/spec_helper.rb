if ENV['TRAVIS']
  require "codeclimate-test-reporter"
  CodeClimate::TestReporter.start
end

require_relative '../lib/rggen'

require_relative  'support/helper_methods'
require_relative  'support/matchers'
require_relative  'support/config'

