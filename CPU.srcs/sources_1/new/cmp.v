`timescale 1ns / 1ps

// comparator for branch
module cmp(
  input [`XLEN-1:0] a, b,
  input             op_unsigned,
  output            zero,
  output            lt);

  assign zero = (a == b);
  assign lt = (!op_unsigned & ($signed(a) < $signed(b))) | (op_unsigned & (a < b));
endmodule