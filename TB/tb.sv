module tb;
  aes_128 data_i, data_old;
  key_256 key_i, key_old;
  mode mode_i;  
  bit clk, rst_n;
  aes_128 data_o;
  logic data_valid_o, ready_o;

  top dut(.*);

  // Clock Generation
  always #10 clk = ~clk;

  // Monitoring Data Values when Valid
  always @(posedge data_valid_o) $display("Data In: %h, \n Mode: %s, \n Key: %h, \n Encrypted Data: %h \n\n", data_old, mode_i.name, key_old, data_o);
	
  // Perserving added keys and data for monitoring
  always @(posedge ready_o) begin
    data_old = data_i;
    key_old = key_i;
  end
initial begin
  $dumpfile("dump.vcd"); $dumpvars;
  clk = 0;
  rst_n = 0;
  #15;
  rst_n = 1;
  mode_i = NOOP;
  #10; 
  $display("Testing ENC_128");
  $display("Case 1:");
  data_i = 128'ha5f132564d5fd2145e65d2a3c214d5e6;
  key_i = {128'h2475A2B33475568831E2120013AA5487, 128'b0};
  mode_i = ENC_128;
  @(posedge ready_o)

  #10;
  data_i = 128'h3243f6a8885a308d313198a2e0370734;
  key_i = {128'h2b7e151628aed2a6abf7158809cf4f3c, 128'b0};
  @(posedge ready_o)
  $display("Case 2:");

  #10;
  data_i = 128'h00112233445566778899aabbccddeeff;
  key_i = {128'h000102030405060708090a0b0c0d0e0f, 128'b0};
  @(posedge ready_o)
  $display("Case 3:");
  #10;



  $display("Testing ENC_192");
  mode_i = ENC_192;
  key_i = {192'h000102030405060708090a0b0c0d0e0f1011121314151617, 64'b0};	
  @(posedge ready_o)
  $display("Case 4:");
  #10;


  $display("Testing ENC_256");
  mode_i = ENC_256;
  key_i = 256'h000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f;
  @(posedge ready_o)
  $display("Case 5:");
  #40;
  $finish();
end
endmodule
