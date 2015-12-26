require_relative '../lib/rgen'

require_relative  'support/helper_methods'
require_relative  'support/matchers'
require_relative  'support/config'

if ENV['TRAVIS']
  require "codeclimate-test-reporter"
  CodeClimate::TestReporter.start
end
