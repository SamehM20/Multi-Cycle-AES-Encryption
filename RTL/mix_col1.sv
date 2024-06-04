module mix_col1(
    input aes_col data_mx_i,
    output aes_col data_mx_o
);

/*  Multiplication by 2
    By: Shifting Right by two and muxing with 1B if bit 7 is 1
*/
function [7:0] mpx2;
	input [7:0] x;
	mpx2 = {x[6:0], 1'b0}^{3'b0, {2{x[7]}}, 1'b0, {2{x[7]}}};	
endfunction

aes_col data_mpx2;
aes_col data_mpx3;

genvar i;

/*  Generating Columns of Multiplication of 2 and of 3
    Multiplication of 3 by adding (XORing) the value to the Multiplication by 2
*/
generate
    for (i = 0; i < 4; i++) begin: multiplyx2x3
        assign data_mpx2[i] =  mpx2(data_mx_i[i]);
        assign data_mpx3[i] = data_mpx2[i] ^ data_mx_i[i];
    end
endgenerate 

// Mixing the Column
generate
    for (i = 0; i < 4; i++) begin: column_mix
        localparam shortint rm2 = i;
        localparam shortint rm3 = ((i+1)>3)?i-3:i+1;
 
        localparam shortint r0  = ((i+2)>3)?i-2:i+2;
        localparam shortint r1  = ((i+3)>3)?i-1:i+3;

        assign data_mx_o[i] =  data_mpx2[rm2] ^ data_mpx3[rm3] ^ data_mx_i[r0] ^ data_mx_i[r1];
    end
endgenerate 


endmodule