module RgGen
  module VerilogUtility
    class SourceFile < CodeUtility::SourceFile
      ifndef_keyword  :'`ifndef'
      endif_keyword   :'`endif'
      define_keyword  :'`define'
      include_keyword :'`include'
    end
  end
end
