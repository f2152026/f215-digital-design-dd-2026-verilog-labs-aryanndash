// cla4.v
// (Carried forward from Task 3 -- paste in your completed, delay-annotated
// version.)
// Gate-level 4-bit carry-lookahead adder, matching the lecture circuit.
// Every gate needs an explicit delay (constant is fine here, e.g. #(2)) --
// this is the default from Task 2 onward, not a special step.
//
// TODO -- Step 1: generate/propagate signals (one xor + one and per bit)
//   p[i] = a[i] ^ b[i]
//   g[i] = a[i] & b[i]
//
// TODO -- Step 2: direct (non-recursive) carry equations. Verilog's and/or
// primitives accept more than 2 inputs directly, e.g.:
//   and #(2) (t2, p1, p0, g0);
// so you do not need to manually chain 2-input gates.
//   c1 = g0 + p0.cin
//   c2 = g1 + p1.g0 + p1.p0.cin
//   c3 = g2 + p2.g1 + p2.p1.g0 + p2.p1.p0.cin
//   c4 = g3 + p3.g2 + p3.p2.g1 + p3.p2.p1.g0 + p3.p2.p1.p0.cin
//
// TODO -- Step 3: sum bits
//   sum[i] = p[i] ^ c[i]     (c0 = cin)

module cla4(
  input  [3:0] a,
  input  [3:0] b,
  input        cin,
  output [3:0] sum,
  output       cout,
  output       Gblk,
  output       Pblk
);

  wire p0, p1, p2, p3;
  wire g0, g1, g2, g3;
  wire c1, c2, c3;

  // TODO: your gate-level P/G, carry, and sum logic goes here.
  // (cout should be connected to c4.) Remember the delay on every gate.

  xor #(2) (p0, a[0], b[0]);
  xor #(2) (p1, a[1], b[1]);
  xor #(2) (p2, a[2], b[2]);
  xor #(2) (p3, a[3], b[3]);

  and #(1) (g0, a[0], b[0]);
  and #(1) (g1, a[1], b[1]);
  and #(1) (g2, a[2], b[2]);
  and #(1) (g3, a[3], b[3]);

 // c1 = g0 + p0.cin
  wire c1_t1;
  and #(2) (c1_t1, p0, cin);
  or  #(2) (c1, g0, c1_t1);

  // c2 = g1 + p1.g0 + p1.p0.cin
  wire c2_t1, c2_t2;
  and #(2) (c2_t1, p1, g0);
  and #(2) (c2_t2, p1, p0, cin);
  or  #(2) (c2, g1, c2_t1, c2_t2);

  // c3 = g2 + p2.g1 + p2.p1.g0 + p2.p1.p0.cin
  wire c3_t1, c3_t2, c3_t3;
  and #(2) (c3_t1, p2, g1);
  and #(2) (c3_t2, p2, p1, g0);
  and #(2) (c3_t3, p2, p1, p0, cin);
  or  #(2) (c3, g2, c3_t1, c3_t2, c3_t3);

  // c4 (cout) = g3 + p3.g2 + p3.p2.g1 + p3.p2.p1.g0 + p3.p2.p1.p0.cin
  wire c4_t1, c4_t2, c4_t3, c4_t4;
  and #(2) (c4_t1, p3, g2);
  and #(2) (c4_t2, p3, p2, g1);
  and #(2) (c4_t3, p3, p2, p1, g0);
  and #(2) (c4_t4, p3, p2, p1, p0, cin);
  or  #(2) (cout, g3, c4_t1, c4_t2, c4_t3, c4_t4);

  xor #(2) (sum[0], p0, cin);
  xor #(2) (sum[1], p1, c1);
  xor #(2) (sum[2], p2, c2);
  xor #(2) (sum[3], p3, c3);

  or  #(2) (Gblk, g3, c4_t1, c4_t2, c4_t3);
  and #(2) (Pblk, p0, p1, p2, p3);

endmodule
