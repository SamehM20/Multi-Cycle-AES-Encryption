`ifndef AES_PACKAGE
    `define AES_PACKAGE 1
    package aes_pkg;
        typedef logic [0:3][31:0] aes_128;
        typedef logic [0:7][31:0] key_256; 
        typedef logic [0:3][7:0] aes_col;
        typedef enum logic [1:0] {NOOP, ENC_128, ENC_192, ENC_256} mode;
    endpackage
`endif