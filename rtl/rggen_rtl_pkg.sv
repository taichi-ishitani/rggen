package rgge_rtl_types_pkg;
  typedef enum logic {
    RGGEN_READ  = 1'b0,
    RGGEN_WRITE = 1'b1
  } rggen_direction;

  typedef enum logic [1:0] {
    RGGEN_OKAY          = 2'b00,
    RGGEN_EXOKAY        = 2'b01,
    RGGEN_SLAVE_ERROR   = 2'b10,
    RGGEN_DECODE_ERROR  = 2'b11
  } rggen_status;

  typedef enum bit {
    RGGEN_SET_MODE    = 1'b0,
    RGGEN_CLEAR_MODE  = 1'b1
  } rggen_rwsc_mode;

  typedef enum bit {
    RGGEN_LOCK_MODE   = 1'b0,
    RGGEN_ENABLE_MODE = 1'b1
  } rggen_rwle_mode;
endpackage
