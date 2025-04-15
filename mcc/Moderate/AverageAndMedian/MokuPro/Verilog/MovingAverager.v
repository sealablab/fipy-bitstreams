module MovingAverage #(
  parameter G_AVERAGE_LENGTH_LOG = 10  // This parameter controls the size of the moving average window 
				       // The window size is 2^G_AVERAGE_LENGTH_LOG samples
)(
  input wire Clk,                      // Clock signal for synchronous operation
  input wire Reset,                    // Reset signal to reset internal states
  input wire signed [15:0] InputA,     // Signed 16-bit input A
  input wire signed [15:0] InputB,     // Signed 16-bit input B
  input wire [15:0] Control0,          // 16-bit control input
  input wire [15:0] Control1,          // 16-bit control input
  output wire signed [15:0] OutputA,   // Signed 16-bit result output
  output wire signed [15:0] OutputB    // Signed 16-bit result output
);

  // Intermediate registers
  reg signed [15:0] p_moving_average [0:2**G_AVERAGE_LENGTH_LOG-1];  // Memory (array) to store the previous N input samples
  reg signed [16+G_AVERAGE_LENGTH_LOG-1:0] r_acc;                    // Register to store the running sum of the input values in the buffer
  reg r_data_valid;                                                  // Flag to indicate when valid averaged data is available
  reg signed [15:0] temp_reg;                                        // Register to store final averaged result

  // Synchronous (runs once every clock cycle) logic block
  always @ (posedge Clk) begin
    if (Reset == 1'b1) begin                                         // If Reset is high, clear everything:
      r_acc <= '{default: '0};                                       // Set the accumulator to zero
      p_moving_average <= '{default: '0};                            // Clear all stored input samples
      temp_reg <= 16'd0;                                             // Set output register to zero
    end else begin
      p_moving_average <= {InputA, p_moving_average[0:2**G_AVERAGE_LENGTH_LOG-2]};  // Shift the values in the buffer to make room for the new input
      r_acc <= r_acc + InputA - p_moving_average[2**G_AVERAGE_LENGTH_LOG-1];        // Add new input sample value and subtract removed sample value from running sum
      temp_reg <= r_acc[16+G_AVERAGE_LENGTH_LOG-1:G_AVERAGE_LENGTH_LOG];            // Divide running sum by window size by shifting bits to the right
    end
  end

  // Assign the averaged result to the output
  assign OutputA = temp_reg;  

endmodule