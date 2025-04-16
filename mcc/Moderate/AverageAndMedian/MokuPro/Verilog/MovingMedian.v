module MovingMedian (
  input wire Clk,                            // Clock signal
  input wire Reset,                          // Synchronous reset
  input wire signed [15:0] Input,            // Input (signed 16-bit)
  output wire signed [15:0] Output           // Output median value (signed 16-bit)
);

  // Holds the last 5 input values
  reg signed [15:0] moving_window [0:4];

  // Multi-stage sorting pipeline: 6 stages, each with 5 values
  reg signed [15:0] staged_sort [0:5][0:4];

  // Holds the final median value after all sorting stages
  reg signed [15:0] median;

  ///////////////////////////////////////////////
  // Shift in new data into moving window buffer
  ///////////////////////////////////////////////
  always@(posedge Clk) begin
    integer j;
    if (Reset == 1'b1)
      for (j=0; j<4; j=j+1) begin
        moving_window[j] <= 16'd0;                  // Clear window on reset
      end 
    else
      moving_window <= {Input, moving_window[0:3]}; // Shift and insert new sample
  end

  ////////////////////////////////////////////////////////
  // Pipelined sorting network to compute median value
  ////////////////////////////////////////////////////////
  always@(posedge Clk) begin
    reg signed [15:0] temp;
    integer i, j;
    reg signed [15:0] sort_var [0:4];

    if (Reset == 1'b1) begin
      for (i=0; i<5; i=i+1) begin
        for (j=0; j<6; j=j+1) begin
          staged_sort[i][j] <= 0;                   // Clear sorting pipeline
        end
      end
      median <= 16'd0;
    end else begin

      ////////////////////////////////////////////////////////////////////////////
      // Stage 0: Load the current moving window into the first stage
      ////////////////////////////////////////////////////////////////////////////
      staged_sort[0] <= moving_window;

      ////////////////////////////////////////////////////////////////////////////
      // Stage 1: Compare and sort pairs (0,1) and (2,3)
      ////////////////////////////////////////////////////////////////////////////
      if (staged_sort[0][0] > staged_sort[0][1]) begin
        staged_sort[1][0] <= staged_sort[0][1];
        staged_sort[1][1] <= staged_sort[0][0];
      end else begin
        staged_sort[1][0] <= staged_sort[0][0];
        staged_sort[1][1] <= staged_sort[0][1];
      end

      if (staged_sort[0][2] > staged_sort[0][3]) begin
        staged_sort[1][2] <= staged_sort[0][3];
        staged_sort[1][3] <= staged_sort[0][2];
      end else begin
        staged_sort[1][2] <= staged_sort[0][2];
        staged_sort[1][3] <= staged_sort[0][3];
      end

      staged_sort[1][4] <= staged_sort[0][4]; // Element 4 remains unprocessed in this stage

      ////////////////////////////////////////////////////////////////////////////
      // Stage 2: Compare (1,2) and (3,4), pass 0 through unchanged
      ////////////////////////////////////////////////////////////////////////////
      staged_sort[2][0] <= staged_sort[1][0];

      if (staged_sort[1][1] > staged_sort[1][2]) begin
        staged_sort[2][1] <= staged_sort[1][2];
        staged_sort[2][2] <= staged_sort[1][1];
      end else begin
        staged_sort[2][1] <= staged_sort[1][1];
        staged_sort[2][2] <= staged_sort[1][2];
      end

      if (staged_sort[1][3] > staged_sort[1][4]) begin
        staged_sort[2][3] <= staged_sort[1][4];
        staged_sort[2][4] <= staged_sort[1][3];
      end else begin
        staged_sort[2][3] <= staged_sort[1][3];
        staged_sort[2][4] <= staged_sort[1][4];
      end

      ////////////////////////////////////////////////////////////////////////////
      // Stage 3: Compare (0,1) and (2,3), pass 4 through
      ////////////////////////////////////////////////////////////////////////////
      if (staged_sort[2][0] > staged_sort[2][1]) begin
        staged_sort[3][0] <= staged_sort[2][1];
        staged_sort[3][1] <= staged_sort[2][0];
      end else begin
        staged_sort[3][0] <= staged_sort[2][0];
        staged_sort[3][1] <= staged_sort[2][1];
      end

      if (staged_sort[2][2] > staged_sort[2][3]) begin
        staged_sort[3][2] <= staged_sort[2][3];
        staged_sort[3][3] <= staged_sort[2][2];
      end else begin
        staged_sort[3][2] <= staged_sort[2][2];
        staged_sort[3][3] <= staged_sort[2][3];
      end

      staged_sort[3][4] <= staged_sort[2][4];

      ////////////////////////////////////////////////////////////////////////////
      // Stage 4: Compare (1,2) and (3,4), pass 0 through
      ////////////////////////////////////////////////////////////////////////////
      staged_sort[4][0] <= staged_sort[3][0];

      if (staged_sort[3][1] > staged_sort[3][2]) begin
        staged_sort[4][1] <= staged_sort[3][2];
        staged_sort[4][2] <= staged_sort[3][1];
      end else begin
        staged_sort[4][1] <= staged_sort[3][1];
        staged_sort[4][2] <= staged_sort[3][2];
      end

      if (staged_sort[3][3] > staged_sort[3][4]) begin
        staged_sort[4][3] <= staged_sort[3][4];
        staged_sort[4][4] <= staged_sort[3][3];
      end else begin
        staged_sort[4][3] <= staged_sort[3][3];
        staged_sort[4][4] <= staged_sort[3][4];
      end

      ////////////////////////////////////////////////////////////////////////////
      // Stage 5: Final sort pass (0,1) and (2,3), pass 4 through
      ////////////////////////////////////////////////////////////////////////////
      if (staged_sort[4][0] > staged_sort[4][1]) begin
        staged_sort[5][0] <= staged_sort[4][1];
        staged_sort[5][1] <= staged_sort[4][0];
      end else begin
        staged_sort[5][0] <= staged_sort[4][0];
        staged_sort[5][1] <= staged_sort[4][1];
      end

      if (staged_sort[4][2] > staged_sort[4][3]) begin
        staged_sort[5][2] <= staged_sort[4][3];
        staged_sort[5][3] <= staged_sort[4][2];
      end else begin
        staged_sort[5][2] <= staged_sort[4][2];
        staged_sort[5][3] <= staged_sort[4][3];
      end

      staged_sort[5][4] <= staged_sort[4][4];

      ////////////////////////////////////////////////////////////////////////////
      // After all sorting stages, pick the median value (middle of sorted 5)
      ////////////////////////////////////////////////////////////////////////////
      median <= staged_sort[5][2];
    end
  end

  // Output the median value
  assign Output = median;

endmodule