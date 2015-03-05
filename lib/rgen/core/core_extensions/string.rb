class String
  VERILOG_IDENTIFIER_PATTERN  = /\A[a-z_][a-z0-9_$]*\z/i.freeze

  def verilog_identifer?
    VERILOG_IDENTIFIER_PATTERN.match(self).not_nil?
  end
end
