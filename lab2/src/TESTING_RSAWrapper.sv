module Rsa256Wrapper (
    input         avm_rst,
    input         avm_clk,
    output  [4:0] avm_address,
    output        avm_read,
    input  [31:0] avm_readdata,
    output        avm_write,
    output [31:0] avm_writedata,
    input         avm_waitrequest
);

localparam RX_BASE     = 0*4;
localparam TX_BASE     = 1*4;
localparam STATUS_BASE = 2*4;
localparam TX_OK_BIT   = 6;
localparam RX_OK_BIT   = 7;

// Feel free to design your own FSM!
localparam S_GET_KEY_N = 0;
localparam S_GET_KEY_D = 1;
localparam S_GET_DATA = 2;
localparam S_WAIT_CALCULATE = 3;
localparam S_SEND_DATA = 4;

logic [255:0] n_r, n_w, d_r, d_w, enc_r, enc_w, dec_r, dec_w;
logic [2:0] state_r, state_w;
logic [6:0] bytes_counter_r, bytes_counter_w;
logic [4:0] avm_address_r, avm_address_w;
logic avm_read_r, avm_read_w, avm_write_r, avm_write_w;

logic rsa_start_r, rsa_start_w;
logic rsa_finished;
logic [255:0] rsa_dec;

assign avm_address = avm_address_r;
assign avm_read = avm_read_r;
assign avm_write = avm_write_r;
assign avm_writedata = dec_r[247-:8]; 
         

Rsa256Core rsa256_core(
    .i_clk(avm_clk),
    .i_rst(avm_rst),
    .i_start(rsa_start_r),
    .i_a(enc_r),
    .i_d(d_r),
    .i_n(n_r),
    .o_a_pow_d(rsa_dec),
    .o_finished(rsa_finished)
);

task StartRead;
    input [4:0] addr;
    begin
        avm_read_w = 1;
        avm_write_w = 0;
        avm_address_w = addr;
    end
endtask
task StartWrite;
    input [4:0] addr;
    begin
        avm_read_w = 0;
        avm_write_w = 1;
        avm_address_w = addr;
    end
endtask

always_comb begin
    //state
    case(state_r)
        S_GET_KEY_N: begin
            if(bytes_counter_r == 31 && avm_address_r == RX_BASE) state_w = S_GET_KEY_D;
            else state_w = state_r;
        end
        S_GET_KEY_D: begin
            if(bytes_counter_r == 63 && avm_address_r == RX_BASE) state_w = S_GET_DATA;
            else state_w = state_r;
        end
        S_GET_DATA: begin
            if(bytes_counter_r == 95 && avm_address_r == RX_BASE) state_w = S_WAIT_CALCULATE;
            else state_w = state_r;
        end
        S_WAIT_CALCULATE: begin
            if(rsa_finished) state_w = S_SEND_DATA;
            else state_w = state_r;
        end
        S_SEND_DATA: begin
            if(bytes_counter_r == 127 && avm_address_r == TX_BASE) state_w = S_GET_KEY_N;
            else state_w = state_r;
        end
        default: begin
            state_w = state_r;
        end
    endcase  
end

always_comb begin
    //bytes_counter 
    bytes_counter_w = bytes_counter_r;
    case(state_r)
        S_GET_KEY_N: if(avm_address_r == RX_BASE ) bytes_counter_w = bytes_counter_r + 1;
        S_GET_KEY_D: if(avm_address_r == RX_BASE ) bytes_counter_w = bytes_counter_r + 1;
        S_GET_DATA: if(avm_address_r == RX_BASE ) bytes_counter_w = bytes_counter_r + 1;
        S_WAIT_CALCULATE: begin
            if(bytes_counter_r == 96) bytes_counter_w = bytes_counter_r + 1;
            else bytes_counter_w = bytes_counter_r;
        end
        S_SEND_DATA: begin
            if(bytes_counter_r == 127) bytes_counter_w = 0;
            else begin
                if(avm_address_r == TX_BASE) bytes_counter_w = bytes_counter_r + 1;
            end
        end
        default: begin
            bytes_counter_w = bytes_counter_r;
        end
    endcase
end

always_comb begin
    //RSA_START control
    rsa_start_w = rsa_start_r;
    case(state_r)
        S_WAIT_CALCULATE: begin
            case(bytes_counter_r) 
                7'd96: rsa_start_w = 1;
                7'd97: rsa_start_w = 0;
                default: rsa_start_w = rsa_start_r;
            endcase
        end
        default: rsa_start_w = rsa_start_r;
    endcase
end

always_comb begin
    // read/write avm_address 
    avm_read_w = avm_read_r;
    avm_write_w = avm_write_r;
    avm_address_w = avm_address_r;
    case(state_r)
        S_GET_KEY_N: begin
            if(!avm_waitrequest && avm_readdata[RX_OK_BIT] && avm_address_r == STATUS_BASE) StartRead(RX_BASE);
            if(avm_address_r == RX_BASE) StartRead(STATUS_BASE);
        end
        S_GET_KEY_D: begin
            if(!avm_waitrequest && avm_readdata[RX_OK_BIT] && avm_address_r == STATUS_BASE) StartRead(RX_BASE);
            if(avm_address_r == RX_BASE) StartRead(STATUS_BASE);
        end
        S_GET_DATA: begin
            if(!avm_waitrequest && avm_readdata[RX_OK_BIT] && avm_address_r == STATUS_BASE) StartRead(RX_BASE);
            if(avm_address_r == RX_BASE) StartRead(STATUS_BASE);
        end
        S_SEND_DATA: begin
            if(!avm_waitrequest && avm_readdata[TX_OK_BIT] && avm_address_r == STATUS_BASE) StartWrite(TX_BASE);
            if(avm_address_r == TX_BASE) StartRead(STATUS_BASE);
        end
        default: begin
            avm_read_w = avm_read_r;
            avm_write_w = avm_write_r;
            avm_address_w = avm_address_r;
        end
    endcase
end

always_comb begin
    // N,D,ENCODE Text
    n_w = n_r;
    d_w = d_r;
    enc_w = enc_r;
    case(state_r)
        S_GET_KEY_N: if(avm_address_r == RX_BASE) n_w[(bytes_counter_r * 8 + 7)-:8] = avm_readdata[7:0];
        S_GET_KEY_D: if(avm_address_r == RX_BASE) d_w[((bytes_counter_r - 32) * 8 + 7)-:8] = avm_readdata[7:0];
        S_GET_DATA: if(avm_address_r == RX_BASE) enc_w[((bytes_counter_r - 64) * 8 + 7)-:8] = avm_readdata[7:0];
        default: begin
            n_w = n_r;
            d_w = d_r;
            enc_w = enc_r;
        end
    endcase
end

always_comb begin
    //DECODE
    dec_w = dec_r;
    case(state_r)
        S_WAIT_CALCULATE: if(rsa_finished) dec_w = rsa_dec;
        S_SEND_DATA: begin
            if(avm_address_r == TX_BASE) dec_w = dec_r << 8; 
        end
        default: dec_w = dec_r;
    endcase
end



always_ff @(posedge avm_clk or posedge avm_rst) begin
    if (avm_rst) begin
        n_r <= 0;
        d_r <= 0;
        enc_r <= 0;
        dec_r <= 0;
        avm_address_r <= STATUS_BASE;
        avm_read_r <= 1;
        avm_write_r <= 0;
        state_r <= S_GET_KEY_N;
        bytes_counter_r <= 0;
        rsa_start_r <= 0;
    end else begin
        n_r <= n_w;
        d_r <= d_w;
        enc_r <= enc_w;
        dec_r <= dec_w;
        avm_address_r <= avm_address_w;
        avm_read_r <= avm_read_w;
        avm_write_r <= avm_write_w;
        state_r <= state_w;
        bytes_counter_r <= bytes_counter_w;
        rsa_start_r <= rsa_start_w;
    end
end

endmodule
