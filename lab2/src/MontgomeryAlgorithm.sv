//MontgomeryAlgorithm
module MontgomeryAlgorithm (
	input          i_clk,
	input          i_rst,
	input          i_valid,
    input  [255:0] i_N,
    input  [255:0] i_m,	
    input  [255:0] i_t,
	output [255:0] o_montgomeryalgorithm,
	output         o_ready
); 


    parameter S_IDLE = 2'd0;
    parameter S_CAL = 2'd1;
    parameter S_OUT = 2'd2;

    logic [256:0] m, m_nxt;
    logic ready, ready_nxt;
    logic [1:0] state, state_nxt;
    logic [8:0] counter, counter_nxt;

    assign o_montgomeryalgorithm = m;
    assign o_ready = ready;

    always_comb begin
        case(state)
            S_IDLE: begin
                if(i_valid) state_nxt = S_CAL;
                else state_nxt = state;
            end
            S_CAL: begin
                if(counter >= 9'd255) state_nxt = S_OUT;
                else state_nxt = state;
            end
            S_OUT: begin
                if(counter >= 9'd258) state_nxt = S_IDLE;
                else state_nxt = state;
            end
            default: state_nxt = state;
        endcase
    end

    always_comb begin
        case(state)
            S_IDLE: begin
                counter_nxt = 9'd0;
            end
            S_CAL: begin
                counter_nxt = counter + 9'd1;
            end
            S_OUT: begin
                counter_nxt = counter + 9'd1; 
            end
            default: counter_nxt = counter;
        endcase
    end

    always_comb begin 
        case(state)
            S_IDLE: begin
                m_nxt = 257'd0;
                ready_nxt = 1'd0;
            end

            S_CAL: begin
                if(i_m[counter] == 1) begin
                    if(((m + i_t) % 2) == 1) m_nxt = (m + i_t + i_N) >> 1;
                    else m_nxt = (m + i_t) >> 1;
                end
                else begin
                    if(m[0] == 1) m_nxt = (m + i_N) >> 1;
                    else m_nxt = m >> 1;
                end
                ready_nxt = ready;
            end

            S_OUT: begin
                case(counter)
                    9'd256: begin
                        if(m >= i_N) m_nxt = m - i_N;
                        else m_nxt = m;
                        ready_nxt = ready;
                    end
                    9'd257: begin
                        m_nxt = m;
                        ready_nxt = 1'd1;
                    end
                    9'd258: begin
                        m_nxt = m;
                        ready_nxt = 1'd0;
                    end
                    default: begin
                        m_nxt = m;
                        ready_nxt = ready;
                    end
                endcase 
            end

            default: begin
                m_nxt = m;
                ready_nxt = ready;
            end
        endcase
    end

    always_ff @(posedge i_clk or posedge i_rst) begin
        if(i_rst)begin
            state <= S_IDLE;
            counter <= 9'd0;
            m <= 257'd0;
            ready <= 1'd0;
        end
        else begin
            state <= state_nxt;
            counter <= counter_nxt;
            m <= m_nxt;
            ready <= ready_nxt;
            //$display("%d", m);
        end

    end

endmodule