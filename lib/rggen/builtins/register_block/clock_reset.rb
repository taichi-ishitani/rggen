simple_item :register_block, :clock_reset do
  rtl do
    build do
      input :register_block, :clock, name: 'clk'  , data_type: :logic, width: 1
      input :register_block, :reset, name: 'rst_n', data_type: :logic, width: 1
    end
  end
end
