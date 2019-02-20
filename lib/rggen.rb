module RgGen
  require 'forwardable'
  require 'singleton'
  require 'pathname'
  require 'optparse'
  require 'erubi'
  require 'csv'
  require 'roo'
  require 'spreadsheet'

  require_relative 'rggen/version'
  require_relative 'rggen/rggen_home'

  require_relative 'rggen/exceptions'

  require_relative 'rggen/core_extensions/array'
  require_relative 'rggen/core_extensions/facets'
  require_relative 'rggen/core_extensions/forwardable'
  require_relative 'rggen/core_extensions/integer'
  require_relative 'rggen/core_extensions/math'
  require_relative 'rggen/core_extensions/roo'

  require_relative 'rggen/base/hierarchical_accessors'
  require_relative 'rggen/base/hierarchical_item_accessors'
  require_relative 'rggen/base/internal_struct'
  require_relative 'rggen/base/component'
  require_relative 'rggen/base/item'
  require_relative 'rggen/base/component_factory'
  require_relative 'rggen/base/item_factory'

  require_relative 'rggen/input_base/regexp_patterns'
  require_relative 'rggen/input_base/component'
  require_relative 'rggen/input_base/item'
  require_relative 'rggen/input_base/loader'
  require_relative 'rggen/input_base/component_factory'
  require_relative 'rggen/input_base/item_factory'

  require_relative 'rggen/output_base/code_generator'
  require_relative 'rggen/output_base/template_engine'
  require_relative 'rggen/output_base/file_writer'
  require_relative 'rggen/output_base/component'
  require_relative 'rggen/output_base/item'
  require_relative 'rggen/output_base/component_factory'
  require_relative 'rggen/output_base/item_factory'

  require_relative 'rggen/builder/simple_item_entry'
  require_relative 'rggen/builder/list_item_entry'
  require_relative 'rggen/builder/item_store'
  require_relative 'rggen/builder/component_entry'
  require_relative 'rggen/builder/component_store'
  require_relative 'rggen/builder/input_component_store'
  require_relative 'rggen/builder/output_component_store'
  require_relative 'rggen/builder/category'
  require_relative 'rggen/builder/builder'

  require_relative 'rggen/options'
  require_relative 'rggen/option_switches'
  require_relative 'rggen/generator'

  require_relative 'rggen/commands'

  require_relative 'rggen/core_components'
  require_relative 'rggen/builtins'
end
