
`define REF_MAX_LENGTH              128
`define READ_MAX_LENGTH             128

`define REF_LENGTH                  128
`define READ_LENGTH                 128

//* Score parameters
`define DP_SW_SCORE_BITWIDTH        10

`define CONST_MATCH_SCORE           1
`define CONST_MISMATCH_SCORE        -4
`define CONST_GAP_OPEN              -6
`define CONST_GAP_EXTEND            -1

module SW_Wrapper (
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

localparam S_GET_REF = 0;
localparam S_GET_READ = 1;
localparam S_WAIT_CALCULATE = 2;
localparam S_SEND_DATA = 3;


logic [1:0] state_r, state_w;
logic [6:0] counter_r, counter_w;

logic [4:0] avm_address_r, avm_address_w;
logic avm_read_r, avm_read_w, avm_write_r, avm_write_w;
logic sw_valid_r, sw_valid_w;
logic sw_inready_r, sw_inready_w;
logic rst_r, rst_w;
logic sw_outready;
logic sw_finished;
logic [255:0] ans_r, ans_w;
logic [255:0] ref_seq_r, ref_seq_w;
logic [255:0] read_seq_r, read_seq_w;

logic [9:0] alignment_score;
logic [6:0] column, row;

assign avm_address = avm_address_r;
assign avm_read = avm_read_r;
assign avm_write = avm_write_r;
assign avm_writedata = ans_r[247-:8]; 
assign core_rst = avm_rst | rst_r;

// Remember to complete the port connection
SW_core sw_core(
    .clk				(avm_clk),
    .rst				(core_rst),

	.o_ready			(sw_outready),
    .i_valid			(sw_valid_r),
    .i_sequence_ref		(ref_seq_r),
    .i_sequence_read	(read_seq_r),
    .i_seq_ref_length	(8'd128),
    .i_seq_read_length	(8'd128),
    
    .i_ready			(sw_inready_r),
    .o_valid			(sw_finished),
    .o_alignment_score	(alignment_score),
    .o_column			(column),
    .o_row				(row)
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

// TODO

always_comb begin
    ref_seq_w = ref_seq_r;
    read_seq_w = read_seq_r;
    case(state_r)
        S_GET_REF: if(!avm_waitrequest && avm_address_r == RX_BASE) ref_seq_w[255-8*counter_r -: 8] = avm_readdata[7:0];
        S_GET_READ: if(!avm_waitrequest && avm_address_r == RX_BASE) read_seq_w[255-8*counter_r[4:0] -: 8] = avm_readdata[7:0];
    endcase
end

always_comb begin
    counter_w = counter_r;
    case(state_r)
        S_GET_REF: if(!avm_waitrequest && avm_address_r == RX_BASE ) counter_w = counter_r + 1;
        S_GET_READ: if(!avm_waitrequest && avm_address_r == RX_BASE ) counter_w = counter_r + 1;
        S_WAIT_CALCULATE: counter_w = 0;
        S_SEND_DATA: begin
            if(!avm_waitrequest && counter_r == 6'b011110 && avm_address_r == TX_BASE) counter_w = 0;
            else begin
                if(!avm_waitrequest && avm_address_r == TX_BASE) counter_w = counter_r + 1;
            end
        end   
    endcase
end

always_comb begin
    state_w = state_r;
    case(state_r)
        S_GET_REF: if(!avm_waitrequest && avm_address_r == RX_BASE && counter_r == 6'b011111) state_w = S_GET_READ;
        S_GET_READ: if(!avm_waitrequest && avm_address_r == RX_BASE && counter_r == 6'b111111) state_w = S_WAIT_CALCULATE;
        S_WAIT_CALCULATE: if(sw_finished) state_w = S_SEND_DATA;
        S_SEND_DATA: if(!avm_waitrequest && avm_address_r == TX_BASE && counter_r == 6'b011110) state_w = S_GET_REF;
    endcase
end



always_comb begin
    // read/write avm_address 
    avm_read_w = avm_read_r;
    avm_write_w = avm_write_r;
    avm_address_w = avm_address_r;
    case(state_r)
        S_GET_REF: begin
            if(!avm_waitrequest && avm_readdata[RX_OK_BIT] && avm_address_r == STATUS_BASE) StartRead(RX_BASE);
            if(!avm_waitrequest && avm_address_r == RX_BASE) StartRead(STATUS_BASE);
        end
        S_GET_READ: begin
            if(!avm_waitrequest && avm_readdata[RX_OK_BIT] && avm_address_r == STATUS_BASE) StartRead(RX_BASE);
            if(!avm_waitrequest && avm_address_r == RX_BASE) StartRead(STATUS_BASE);
        end
        S_SEND_DATA: begin
            if(!avm_waitrequest && avm_readdata[TX_OK_BIT] && avm_address_r == STATUS_BASE) StartWrite(TX_BASE);
            if(!avm_waitrequest && avm_address_r == TX_BASE) StartRead(STATUS_BASE);
        end
        default: begin
            avm_read_w = avm_read_r;
            avm_write_w = avm_write_r;
            avm_address_w = avm_address_r;
        end
    endcase
end

// shift ans
always_comb begin
    ans_w = ans_r;
    case(state_r)
        S_WAIT_CALCULATE: begin
            if(sw_finished) begin
                ans_w[9:0] = alignment_score;
                ans_w[70:64] = row;
                ans_w[134:128] = column;

            end
        end
        S_SEND_DATA: begin
            if(!avm_waitrequest && avm_address_r == TX_BASE) ans_w = ans_r << 8; 
        end
        default: ans_w = ans_r;
    endcase
end

// valid & ready
always_comb begin
    sw_valid_w = sw_valid_r;
    sw_inready_w = sw_inready_r;
    rst_w = rst_r;
    case(state_r)
        S_GET_READ: if(!avm_waitrequest && avm_address_r == RX_BASE && counter_r == 6'b111111) rst_w = 1;
        S_WAIT_CALCULATE: begin
            rst_w = 0;
            sw_valid_w = 1'b1;
            sw_inready_w = 1'b1;
            if(sw_finished) begin
                sw_valid_w = 1'b0;
                sw_inready_w = 1'b0;
            end
        end
    endcase
end

// TODO
always_ff @(posedge avm_clk or posedge avm_rst) begin
    if (avm_rst) begin
    	state_r <= 0;
        counter_r <= 0;
        avm_address_r <= STATUS_BASE;
        avm_read_r <= 1;
        avm_write_r <= 0;
        sw_valid_r <= 0;
        sw_inready_r <= 0;
        ans_r <= 0;
        ref_seq_r <= 0;
        read_seq_r <= 0;
        rst_r <= 0;
    end
	else begin
    	state_r <= state_w;
        counter_r <= counter_w;
        avm_address_r <= avm_address_w;
        avm_read_r <= avm_read_w;
        avm_write_r <= avm_write_w;
        sw_valid_r <= sw_valid_w;
        sw_inready_r <= sw_inready_w;
        ans_r <= ans_w;
        ref_seq_r <= ref_seq_w;
        read_seq_r <= read_seq_w;
        rst_r <= rst_w;
    end
end

endmodule

