simple_item(:register_block, :clock_reset) do
  rtl do
    build do
      input :clock, name: 'clk'  , width: 1
      input :reset, name: 'rst_n', width: 1
    end
  end
end
