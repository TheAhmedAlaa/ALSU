package pkg_Q3;
  typedef enum logic [2:0] {
    OR,
    XOR,
    ADD,
    MULT,
    SHIFT,
    ROTATE,
    INVALID_6,
    INVALID_7
  } opcode_typedef;  //defining an opcode so it takes these values only 
  parameter MAXPOS = 3;
  parameter MAXNEG = -4;
  parameter ZERO = 0;  //parameters for easy use
  parameter INPUT_PRIORITY = "A";
  parameter FULL_ADDER = "ON";
  class ALSU_class;
    rand logic [2:0] A, B;  //we want to random
    rand
    opcode_typedef
    opcode; //defining opcode with opcode_typedef so it takes values of the parameters and randomize it 
    rand
    logic
        cin,
        serial_in,
        direction,
        red_op_A,
        red_op_B,
        bypass_A,
        bypass_B,
        rst;  //we want to random 
    constraint cons {
      rst dist {
        0 := 95,
        1 := 5
      };  //rst has 95% of it to work
      opcode dist {
        OR := 15,
        XOR := 15,
        ADD := 15,
        MULT := 15,
        SHIFT := 15,
        ROTATE := 15,
        INVALID_6 := 5,
        INVALID_7 := 5
      };
      bypass_A == 0;
      bypass_B == 0;
      if (opcode == ADD || opcode == MULT) {
        A dist {
          MAXPOS := 45,
          MAXNEG := 45,
          ZERO   := 30
        };
        B dist {
          MAXPOS := 45,
          MAXNEG := 45,
          ZERO   := 30
        };
      }  //if opcode is add or mult so it will achive these random values of a,b
      if ((opcode == OR || opcode == XOR) && red_op_A) {
        A dist {
          1 := 10,
          2 := 10,
          4 := 10
        };
        B == 0;
      }
      if ((opcode == OR || opcode == XOR) && red_op_B) {
        B dist {
          1 := 10,
          2 := 10,
          4 := 10
        };
        A == 0;
      }

    }
  endclass  //

endpackage
