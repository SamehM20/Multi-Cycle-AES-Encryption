/*
||||||||||||||||||||||||||||||||||||||||||||
||||||||||||||||||||||||||||||||||||||||||||
||||||/ ___|  / \  |  \/  | ____| | | ||||||  
||||||\___ \ / _ \ | |\/| |  _| | |_| ||||||  
|||||| ___) / ___ \| |  | | |___|  _  ||||||  
|||||||____/_/ __\_\_| _|_|_____|_|_|_||||||  
|| ____| |   | __ )  / \|_   _/ ___|| | | || 
||  _| | |   |  _ \ / _ \ | | \___ \| |_| || 
|| |___| |___| |_) / ___ \| |  ___) |  _  || 
||_____|_____|____/_/   \_\_| |____/|_| |_|| 
||||||||||||||||||||||||||||||||||||||||||||
||||||||||||||||||||||||||||||||||||||||||||
  LinkedIn: linkedin.com/in/sameh-elbatsh/
||||||||||||||||||||||||||||||||||||||||||||
Pipelined AES Encryption Implementation
Modes Included:
    - NOOP: Halts the Operation of the Module Perserving the State
    - 128-bit key encryption.
    - 192-bit key encryption.
    - 256-bit key encryption.
The System has an Active Low Synchronous Reset.
*/
import aes_pkg::*;
module top(
    input aes_128 data_i,
    input key_256 key_i,
    input mode mode_i,   
    input clk, rst_n,
    output aes_128 data_o,
    output data_valid_o, ready_o
);

// Rounds Key Words 
aes_128 kw;

// Encryption Module Instatiation
encryptor enc(.kw_i(kw), .*);

// Key Words Expansion Module Instatiation
k_exp exp(.kw_o(kw), .*);

endmodule