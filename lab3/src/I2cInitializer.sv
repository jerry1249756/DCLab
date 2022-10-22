// === I2cInitializer ===
// sequentially sent out settings to initialize WM8731 with I2C protocal
module I2cInitializer(
	input  i_rst_n,
	input  i_clk,
	input  i_start,
	output o_finished,
	output o_sclk,
	output o_sdat,
	output o_oen //output enable (you are not outputing only when you are "ack"ing.)
);

	parameter S_IDLE = 2'd0;
	parameter S_SEND = 2'd1;
	parameter S_FINAL = 2'd2;
	parameter reset = 25'b0001101000001111000000000; //MSB 1st bit prepareation, actually 0011_0100_000_1111_0_0000_0000

	logic SDA, SCL, SDA_nxt, SCL_nxt;
	logic [1:0] state, state_nxt;
	logic [3:0] counter, counter_nxt;
	logic [4:0] data_counter, data_counter_nxt;
	logic o_oen_slow, o_oen_reg;
	
	assign o_sdat = SDA;
	assign o_sclk = SCL;
	assign o_oen = o_oen_reg;
	assign o_oen_slow = (counter == 4'd9 && data_counter < 5'd20) ? 1'd0 : 1'd1;
	assign o_finished = (state == S_FINAL) ? 1'b1 : 1'b0;
	
	always_comb begin
		case(state)
			S_IDLE: begin
				state_nxt = (i_start == 1'd1) ? S_SEND : S_IDLE;
			end
			S_SEND: begin
				state_nxt = (data_counter == 5'd0 && counter == 4'd1)? S_FINAL : S_SEND;
			end
			S_FINAL: begin 
				state_nxt = S_IDLE;
			end
			default: begin
				state_nxt = state;
			end
		endcase
	end	

	always_comb begin
		case(state)
			S_SEND: begin
				if(SCL==1'd1) begin
					counter_nxt = (counter == 4'd9) ?  4'd1 : counter + 4'd1;
					data_counter_nxt = (counter == 4'd9 || data_counter == 5'd0) ?  data_counter : data_counter - 4'd1;
				end
				else begin
					counter_nxt = counter;
					data_counter_nxt = data_counter;
				end
			end
			default: begin
				counter_nxt = counter;
				data_counter_nxt = data_counter;
			end
		endcase
	end

	always_comb begin
		case(state)
			S_SEND: begin
				SDA_nxt = (counter > 24) ? 1'd0 : reset[data_counter];
				SCL_nxt = (counter > 24) ? 1'd1 : !SCL;
			end
			default: begin
				SDA_nxt = 1'd1;
				SCL_nxt = 1'd1;
			end
		endcase
	end

	// ===== Sequential Circuits =====
	always_ff @(posedge i_clk or negedge i_rst_n) begin
		// reset
		if (!i_rst_n) begin
			state <= S_IDLE;
			SCL <= 1'd1;
		end
		else begin
			state <= state_nxt;
			SCL <= SCL_nxt;
		end
	end

	always_ff @(negedge i_clk or negedge i_rst_n) begin
		o_oen_reg <= o_oen_slow;
		// reset
		if (!i_rst_n) begin
			SDA <= 1'd1;
			counter <= 4'd0;
			data_counter <= 5'd24;
		end
		else begin
			SDA <= SDA_nxt;
			counter <= counter_nxt;
			data_counter <= data_counter_nxt;
		end
	end
	



endmodule

