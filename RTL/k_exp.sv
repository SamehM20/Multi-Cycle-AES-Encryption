module k_exp(
    input key_256 key_i,
    input mode mode_i,   
    input clk, rst_n,
    output aes_128 kw_o
);

key_256 kw_int1, kw_int2;
logic [31:0] w_mode;
logic [1:0][31:0] g_int;
logic [7:0] rc_i;

typedef enum logic [2:0]{PRE_ROUND, PRE_ROUND2_256, PRE_ROUND2_192, ROUND2_256, ROUND3_192, ROUND2_192, ROUND, ROUND_192} state_t;
state_t current_state, next_state;

// Max Number of Rounds for each Key Mode
logic [3:0] round_max, crd, crd_r, crd_rc, crd_rc_r;
always_comb begin
    case (mode_i)
        ENC_128: round_max = 10;
        ENC_192: round_max = 12;
        ENC_256: round_max = 14; 
        default: round_max = 0;
    endcase
end

always_ff @(posedge clk) begin
    if(!rst_n) begin    // Active Low Synchronous Reset
        current_state <= PRE_ROUND;
        crd_r <= 1;
        kw_int1 <= 0;
        kw_o <= 0;
        crd_rc_r <= 1;
    end
    else begin 
        kw_int1 <= kw_int2;
        // Output Register Multiplexing
        if((current_state == ROUND)||(current_state == PRE_ROUND)||(current_state == ROUND2_192))
            kw_o <= kw_int2[0:3];
        else if((current_state == PRE_ROUND2_192)||(current_state == ROUND3_192))
            kw_o <= {kw_int2[4:5], kw_int2[0:1]};
        else if((current_state == ROUND_192))
            kw_o <= kw_int2[2:5];
        else
            kw_o <= kw_int2[4:7];
        if(mode_i != NOOP) current_state <= next_state;
        crd_r <= crd;
        crd_rc_r <= crd_rc;
    end
end


// State Transitions
always_comb begin
    crd = crd_r + 1;
    crd_rc = crd_rc_r;
    kw_int2 = kw_int1;
    case (current_state)
        PRE_ROUND: begin
            kw_int2 = key_i;
            if(mode_i == ENC_128) next_state = ROUND;
            else if(mode_i == ENC_192) next_state = PRE_ROUND2_192;
            else if(mode_i == ENC_256) next_state = PRE_ROUND2_256;
            else next_state = PRE_ROUND;
            crd = 1;
            crd_rc = 1;
        end
        PRE_ROUND2_256: begin
            next_state = ROUND;
        end

        ROUND: begin if(crd_r==round_max) next_state = PRE_ROUND; 
            else if(mode_i == ENC_128) next_state = ROUND;
            else next_state = ROUND2_256; 
            crd_rc = crd_rc_r + 1;
            kw_int2[0] = kw_int1[0] ^ g_int[0] ^ {rc_i, 24'b0};
            kw_int2[1] = kw_int1[1] ^ kw_int2[0];
            kw_int2[2] = kw_int1[2] ^ kw_int2[1];
            kw_int2[3] = kw_int1[3] ^ kw_int2[2];
        end 
        ROUND2_256: begin
            next_state = ROUND; 
            kw_int2[4] = kw_int1[4] ^ g_int[1];
            kw_int2[5] = kw_int1[5] ^ kw_int2[4];
            kw_int2[6] = kw_int1[6] ^ kw_int2[5];
            kw_int2[7] = kw_int1[7] ^ kw_int2[6];
        end 
        PRE_ROUND2_192: begin
            next_state = ROUND_192; 
            crd_rc = crd_rc_r + 1;
            kw_int2[4] = kw_int1[4];
            kw_int2[5] = kw_int1[5];
            kw_int2[0] = kw_int1[0] ^ g_int[0] ^ {rc_i, 24'b0};
            kw_int2[1] = kw_int1[1] ^ kw_int2[0];
        end
        ROUND_192: begin
            next_state = ROUND2_192; 
            kw_int2[2] = kw_int1[2] ^ kw_int1[1];
            kw_int2[3] = kw_int1[3] ^ kw_int2[2];
            kw_int2[4] = kw_int1[4] ^ kw_int2[3];
            kw_int2[5] = kw_int1[5] ^ kw_int2[4];
        end
        ROUND2_192: begin
            if(crd_r==round_max) next_state = PRE_ROUND;
            else next_state = ROUND3_192; 
            crd_rc = crd_rc_r + 1;
            kw_int2[0] = kw_int1[0] ^ g_int[0] ^ {rc_i, 24'b0};
            kw_int2[1] = kw_int1[1] ^ kw_int2[0];
            kw_int2[2] = kw_int1[2] ^ kw_int2[1];
            kw_int2[3] = kw_int1[3] ^ kw_int2[2];
        end
        ROUND3_192: begin
            next_state = ROUND_192; 
            crd_rc = crd_rc_r + 1;
            kw_int2[4] = kw_int1[4] ^ kw_int1[3];
            kw_int2[5] = kw_int1[5] ^ kw_int2[4];
            kw_int2[0] = kw_int1[0] ^ g_int[0] ^ {rc_i, 24'b0};
            kw_int2[1] = kw_int1[1] ^ kw_int2[0];
        end
        default: next_state = PRE_ROUND;
    endcase
end

assign w_mode = (mode_i == ENC_256)? kw_int1[7]:
                (mode_i == ENC_192)? kw_int2[5]:
                               kw_int1[3];

bSbox sbe_00(w_mode[7:0], g_int[0][15:8]); //B1
bSbox sbe_01(w_mode[15:8], g_int[0][23:16]); //B2
bSbox sbe_02(w_mode[23:16], g_int[0][31:24]); //B3
bSbox sbe_03(w_mode[31:24], g_int[0][7:0]); //B0

bSbox sbe_10(kw_int1[3][7:0], g_int[1][7:0]); //B0
bSbox sbe_11(kw_int1[3][15:8], g_int[1][15:8]);//B1
bSbox sbe_12(kw_int1[3][23:16], g_int[1][23:16]); //B2
bSbox sbe_13(kw_int1[3][31:24], g_int[1][31:24]); //B3

always_comb begin
    case(crd_rc_r)
        1:  rc_i = 8'h1;
        2:  rc_i = 8'h2;
        3:  rc_i = 8'h4;
        4:  rc_i = 8'h8;
        5:  rc_i = 8'h10;
        6:  rc_i = 8'h20;
        7:  rc_i = 8'h40;
        8:  rc_i = 8'h80;
        9:  rc_i = 8'h1B;
        10: rc_i = 8'h36;
        default: rc_i = 0;
    endcase
end

endmodule
