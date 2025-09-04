import pkg_Q3::*;
module ALSU_tb ();
  logic
      clk,
      cin,
      rst,
      red_op_A,
      red_op_B,
      bypass_A,
      bypass_B,
      direction,
      serial_in,
      red_op_A_reg,
      red_op_B_reg,
      bypass_A_reg,
      bypass_B_reg,
      direction_reg,
      serial_in_reg;
  opcode_typedef opcode, opcode_reg;
  logic signed [2:0] A, B, A_reg, B_reg;
  logic [15:0] leds, leds_tb;
  logic signed [5:0] out, out_tb;
  logic signed [1:0] cin_reg;
  logic [50:0] correct_counter, false_counter;
  ALSU DUT (
      A,
      B,
      cin,
      serial_in,
      red_op_A,
      red_op_B,
      opcode,
      bypass_A,
      bypass_B,
      clk,
      rst,
      direction,
      leds,
      out
  );
  task check(signed [5:0] out, out_tb, unsigned [15:0] leds, leds_tb);
    @(negedge clk);
    if (out === out_tb && leds === leds_tb) begin
      $display("Correct:opcode=%d out=%0d  out_tb=%0d   leds=%h  leds_tb=%h", opcode_reg, out,
               out_tb, leds, leds_tb);
      correct_counter = correct_counter + 1;
    end else begin
      $display("[%0t] FALSE: opcode=%d out=%0d out_tb=%0d  leds=%h leds_tb=%h", $time, opcode_reg,
               out, out_tb, leds, leds_tb);
      false_counter = false_counter + 1;
    end
  endtask
  always @(posedge clk or posedge rst) begin
    if (rst) begin
      cin_reg <= 0;
      red_op_B_reg <= 0;
      red_op_A_reg <= 0;
      bypass_B_reg <= 0;
      bypass_A_reg <= 0;
      direction_reg <= 0;
      serial_in_reg <= 0;
      A_reg <= 0;
      B_reg <= 0;
      out_tb <= 0;  //
      leds_tb <= 0;
    end else begin
      cin_reg <= cin;
      red_op_A_reg <= red_op_A;
      red_op_B_reg <= red_op_B;
      bypass_A_reg <= bypass_A;
      bypass_B_reg <= bypass_B;
      direction_reg <= direction;
      serial_in_reg <= serial_in;
      opcode_reg <= opcode;
      A_reg <= A;
      B_reg <= B;
      //bypass handling 
      if (bypass_A_reg && bypass_B_reg && INPUT_PRIORITY == "A") begin
        out_tb  <= A_reg;
        leds_tb <= 0;
      end else if (bypass_A_reg && bypass_B_reg) begin
        out_tb  <= B_reg;
        leds_tb <= 0;
      end else if (bypass_A_reg) begin
        out_tb  <= A_reg;
        leds_tb <= 0;
      end else if (bypass_B_reg) begin
        out_tb  <= B_reg;
        leds_tb <= 0;
      end  //end of bypass handling
      else begin  //Now if no bypass so this opcode operations occure 
        //first the invalid case if 2. red_op_A or red_op_B are set to high and the opcode is not OR or XOR operation
        if ( ((red_op_A_reg | red_op_B_reg) && !((opcode_reg == OR) || (opcode_reg == XOR)))
     || (opcode_reg == INVALID_6) || (opcode_reg == INVALID_7) ) begin
          out_tb  <= 0;
          leds_tb <= ~leds_tb;
        end else begin
          case (opcode_reg)
            OR: begin
              leds_tb <= 0;
              if (red_op_A_reg && red_op_B_reg && INPUT_PRIORITY == "A") begin
                out_tb <= |A_reg;
              end else if (red_op_A_reg && red_op_B_reg) begin
                out_tb <= |B_reg;
              end else if (red_op_A_reg) begin
                out_tb <= |A_reg;
              end else if (red_op_B_reg) begin
                out_tb <= |B_reg;
              end else out_tb <= A_reg | B_reg;
            end
            XOR: begin
              leds_tb <= 0;
              if (red_op_A_reg && red_op_B_reg && INPUT_PRIORITY == "A") begin
                out_tb <= ^A_reg;
              end else if (red_op_A_reg && red_op_B_reg) begin
                out_tb <= ^B_reg;
              end else if (red_op_A_reg) begin
                out_tb <= ^A_reg;
              end else if (red_op_B_reg) begin
                out_tb <= ^B_reg;
              end else out_tb <= A_reg ^ B_reg;
            end
            ADD: begin
              leds_tb <= 0;
              if (FULL_ADDER == "ON") begin
                out_tb <= A_reg + B_reg + cin_reg;
              end else out_tb <= A_reg + B_reg;
            end
            MULT: begin
              leds_tb <= 0;
              out_tb  <= A_reg * B_reg;
            end
            SHIFT: begin
              leds_tb <= 0;
              if (direction_reg) begin
                out_tb <= {out_tb[4:0], serial_in_reg};
              end else out_tb <= {serial_in_reg, out_tb[5:1]};
            end
            ROTATE: begin
              leds_tb <= 0;
              if (direction_reg) begin
                out_tb <= {out_tb[4:0], out_tb[5]};
              end else out_tb <= {out_tb[0], out_tb[5:1]};
            end
          endcase
        end
      end
    end
  end
  initial begin
    clk = 0;
    forever begin
      #5 clk = ~clk;
    end
  end
  ALSU_class ALSU_;
  initial begin
    correct_counter = 0;
    false_counter = 0;
    ALSU_ = new();
    for (int i = 0; i < 1000; i++) begin
      assert (ALSU_.randomize());
      rst = ALSU_.rst;
      A = ALSU_.A;
      B = ALSU_.B;
      cin = ALSU_.cin;
      opcode = ALSU_.opcode;
      bypass_A = ALSU_.bypass_A;
      bypass_B = ALSU_.bypass_B;
      serial_in = ALSU_.serial_in;
      direction = ALSU_.direction;
      red_op_A = ALSU_.red_op_A;
      red_op_B = ALSU_.red_op_B;
      check(out, out_tb, leds, leds_tb);
    end
    $display("correct_counter=%d,false_counter=%d", correct_counter, false_counter);
    $stop;
  end
endmodule

