simple_item :register_block, :c_header_file do
  c_header do
    delegate [:name] => :register_block

    write_file '<%= name %>.h' do |f|
      f.include_guard
      f.include_file 'rggen.h'
      f.body { |code| source_file_body(code) }
    end

    def source_file_body(code)
      register_block.generate_code(:c_header_item, :top_down, code)
    end
  end
end
