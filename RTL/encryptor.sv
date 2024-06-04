module encryptor(
    input aes_128 data_i, kw_i,
    input mode mode_i,   
    input clk, rst_n,
    output aes_128 data_o,
    output logic data_valid_o, ready_o
);

// Intermediate Signal Declaration
aes_128 data_p, data_sb, data_rs, data_cm, data_rk_in, data_rk;
logic data_valid;

typedef enum logic [1:0]{IDLE, PRE_ROUND, ROUND, FINAL_ROUND} state_t;
state_t current_state, next_state;

// Max Number of Rounds for each Key Mode
logic [3:0] round_max, crd, crd_r;
always_comb begin
    case (mode_i)
        ENC_128: round_max = 9;
        ENC_192: round_max = 11;
        ENC_256: round_max = 13; 
        default: round_max = 0;
    endcase
end

always_ff @(posedge clk) begin
    if(!rst_n) begin    // Active Low Synchronous Reset
        current_state = IDLE;
        data_valid_o = 0;
        data_o = 0;
        crd_r = 1;
        data_p = 0;
    end
    else begin 
        if(mode_i != NOOP) current_state = next_state;
        data_p = data_rk;
        data_valid_o = data_valid;
        if(data_valid) data_o = data_rk;
        crd_r = crd;
    end
end

// State Transitions
always_comb begin
    crd = crd_r + 1;
    data_rk_in = data_cm;
    data_valid = 0;
    ready_o = 0;
    case (current_state)
        IDLE: begin
            next_state = PRE_ROUND;
            ready_o = 1;
        end
        PRE_ROUND: begin
            next_state = ROUND;
            data_rk_in = data_i;
            crd = 1;
            ready_o = 1;
        end
        ROUND: begin 
            if(crd_r == round_max) next_state = FINAL_ROUND;
            else next_state = ROUND;
        end 
        FINAL_ROUND: begin
            next_state = PRE_ROUND;
            data_rk_in = data_rs;
            data_valid = 1;
            ready_o = 1;
        end
        default: next_state = IDLE;
    endcase
end


// Byte Substitution
genvar i, j;
generate
    for (i = 0; i < 4; i++) begin: byte_subs_r
        for (j = 0; j < 4; j++)begin: c
            bSbox sbe(data_p[i][7+j*8:j*8], data_sb[i][7+j*8:j*8]);
        end
    end
endgenerate 

// Row Shifting
assign data_rs[0] = {data_sb[0][31:24],   data_sb[1][23:16], data_sb[2][15:8], data_sb[3][7:0]};
assign data_rs[1] = {data_sb[1][31:24],   data_sb[2][23:16], data_sb[3][15:8], data_sb[0][7:0]};   
assign data_rs[2] = {data_sb[2][31:24],   data_sb[3][23:16], data_sb[0][15:8], data_sb[1][7:0]}; 
assign data_rs[3] = {data_sb[3][31:24],   data_sb[0][23:16], data_sb[1][15:8], data_sb[2][7:0]}; 

// Column Mixing
generate
    for (i = 0; i < 4; i++) begin: mix_column
        mix_col1 col_mx (.data_mx_i({data_rs[i]}),
                         .data_mx_o({data_cm[i]}));
    end
endgenerate  

// Round Key Addition
generate
    for (i = 0; i < 4; i++) begin: round_key_addition   
        for (j = 0; j < 4; j++)begin
          assign data_rk[i][7+j*8:j*8] = data_rk_in[i][7+j*8:j*8] ^ kw_i[i][7+j*8:j*8];
        end
    end
endgenerate 

endmodule
