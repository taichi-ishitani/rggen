require_relative '../../../spec_helper'

module RgGen::VerilogUtility
  describe LocalScope do
    before(:all) do
      @verilog  = Object.new.tap { |o| o.extend RgGen::VerilogUtility }
    end

    def local_scope(name, &body)
      LocalScope.new(name, &body).to_code.to_s
    end

    def signal(attributes)
      @verilog.send(:variable_declaration, attributes)
    end

    it "ローカルスコープを作成するコードを生成する" do
      expect(
        local_scope(:g_foo)
      ).to eq <<'CODE'
generate if (1) begin : g_foo
end endgenerate
CODE

      expect(
        local_scope(:g_foo) { |s|
          s.body { 'assign foo = 0;' }
        }
      ).to eq <<'CODE'
generate if (1) begin : g_foo
  assign foo = 0;
end endgenerate
CODE

      expect(
        local_scope(:g_foo) { |s|
          s.signals []
        }
      ).to eq <<'CODE'
generate if (1) begin : g_foo
end endgenerate
CODE

      expect(
        local_scope(:g_foo) { |s|
          s.signals [signal(data_type: :logic, name: :foo)]
        }
      ).to eq <<'CODE'
generate if (1) begin : g_foo
  logic foo;
end endgenerate
CODE

      expect(
        local_scope(:g_foo) { |s|
          s.signals [
            signal(data_type: :logic, name: :foo),
            signal(data_type: :logic, name: :bar)
          ]
        }
      ).to eq <<'CODE'
generate if (1) begin : g_foo
  logic foo;
  logic bar;
end endgenerate
CODE

      expect(
        local_scope(:g_foo) { |s|
          s.loops {}
        }
      ).to eq <<'CODE'
generate if (1) begin : g_foo
end endgenerate
CODE

      expect(
        local_scope(:g_foo) { |s|
          s.loops g_i: 2
        }
      ).to eq <<'CODE'
generate if (1) begin : g_foo
  genvar g_i;
  for (g_i = 0;g_i < 2;++g_i) begin : g
  end
end endgenerate
CODE

      expect(
        local_scope(:g_foo) { |s|
          s.loops g_i: 2, g_j: 4
        }
      ).to eq <<'CODE'
generate if (1) begin : g_foo
  genvar g_i;
  for (g_i = 0;g_i < 2;++g_i) begin : g
    genvar g_j;
    for (g_j = 0;g_j < 4;++g_j) begin : g
    end
  end
end endgenerate
CODE

      expect(
        local_scope(:g_foo) { |s|
          s.body { 'assign foo = bar;' }
          s.signals [
            signal(data_type: :logic, name: :foo),
            signal(data_type: :logic, name: :bar)
          ]
          s.loops g_i: 2, g_j: 4
        }
      ).to eq <<'CODE'
generate if (1) begin : g_foo
  genvar g_i;
  for (g_i = 0;g_i < 2;++g_i) begin : g
    genvar g_j;
    for (g_j = 0;g_j < 4;++g_j) begin : g
      logic foo;
      logic bar;
      assign foo = bar;
    end
  end
end endgenerate
CODE
    end


  end
end
