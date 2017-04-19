simple_item :register_block, :ral_package do
  ral do
    delegate :name => :register_block

    write_file '<%= name %>_ral_pkg.sv' do |f|
      f.include_guard
      f.body { source_file_body }
    end

    def source_file_body
      package_definition "#{name}_ral_pkg" do |pkg|
        pkg.import_package :uvm_pkg
        pkg.import_package :rggen_ral_pkg
        pkg.include_file   'uvm_macros.svh'
        pkg.include_file   'rggen_ral_macros.svh'
        pkg.body { |code| body_code(code) }
      end
    end

    def body_code(code)
      register_block.generate_code(:package_item, :bottom_up, code)
    end
  end
end
