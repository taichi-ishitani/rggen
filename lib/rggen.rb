module RgGen
  RGGEN_HOME  = File.realpath(File.join(__dir__, '..'))

  require 'forwardable'
  require 'singleton'
  require 'baby_erubis'
  require 'fileutils'
  require 'pathname'
  require 'optparse'

  require_relative 'rggen/version'

  require_relative 'rggen/exceptions'

  require_relative 'rggen/core_extensions/array'
  require_relative 'rggen/core_extensions/facets'
  require_relative 'rggen/core_extensions/forwardable'
  require_relative 'rggen/core_extensions/integer'
  require_relative 'rggen/core_extensions/math'

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

  require_relative 'rggen/output_base/line'
  require_relative 'rggen/output_base/code_block'
  require_relative 'rggen/output_base/code_utility'
  require_relative 'rggen/output_base/template_engine'
  require_relative 'rggen/output_base/verilog_utility/identifier'
  require_relative 'rggen/output_base/verilog_utility/declaration'
  require_relative 'rggen/output_base/verilog_utility/structure_definition'
  require_relative 'rggen/output_base/verilog_utility/module_definition'
  require_relative 'rggen/output_base/verilog_utility/package_definition'
  require_relative 'rggen/output_base/verilog_utility/class_definition'
  require_relative 'rggen/output_base/verilog_utility/subroutine_definition'
  require_relative 'rggen/output_base/verilog_utility'
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

  require_relative 'rggen/generator'

  require_relative 'rggen/commands'

  require_relative 'rggen/core_components'
  require_relative 'rggen/builtins'
end
