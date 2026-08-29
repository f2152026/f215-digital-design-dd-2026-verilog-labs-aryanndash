// cla64_hier.v
// BONUS -- open-ended. No detailed scaffold is provided; this is meant to
// be a genuine design exercise. Not required for lab submission.
//
// You will likely need to modify cla4.v (or add signals alongside it) so
// that block-generate/block-propagate summaries of its own Gi, Pi signals
// are exposed as outputs, since the second-level lookahead unit below
// needs them. As with every module in this lab from Task 2 onward, every
// gate/assign you add should carry an explicit delay.
//
// Starting point (from Tutorial 3, Q4(d)):
//   - Reuse 16 four-bit CLA blocks (your cla4.v) -- their internal logic
//     doesn't change.
//   - For each block k, define:
//       Gblk_k = "this block produces a carry regardless of its incoming
//                 carry" -- a Boolean function of that block's own 4
//                 bit-level Gi, Pi signals.
//       Pblk_k = "an incoming carry sails straight through this whole
//                 block" -- likewise a function of its own Gi, Pi.
//   - Build a second-level lookahead unit -- structurally identical to
//     cla4.v, just one level up -- that computes each block's carry-in
//     directly from Gblk_0..Gblk_15, Pblk_0..Pblk_15, and cin, instead of
//     rippling block to block.
//
// To test this, wire it into dut.v as a fourth option (copy the pattern
// used for the other three) and run it through the same tb.v. Compare
// your final delay to cla64_blocked.v from Task 4.

module cla_la16(
  input  [15:0] Gblk,
  input  [15:0] Pblk,
  input         cin,
  output [15:0] blk_cin,
  output        cout
);
 
  genvar m, j;
 

  wire PPROD [0:15][0:15];
  generate
    for (j = 0; j < 16; j = j + 1) begin : ppdiag
      assign PPROD[j][j] = 1'b1;
    end
    for (m = 1; m < 16; m = m + 1) begin : ppouter
      for (j = 0; j < m; j = j + 1) begin : ppinner
        and #(2) (PPROD[m][j], Pblk[m], PPROD[m-1][j]);
      end
    end
  endgenerate
 

  wire [0:15] PPROD0;
  assign PPROD0[0] = Pblk[0];
  generate
    for (m = 1; m < 16; m = m + 1) begin : pp0
      and #(2) (PPROD0[m], Pblk[m], PPROD0[m-1]);
    end
  endgenerate
 

  wire term [0:15][0:15];
  generate
    for (m = 0; m < 16; m = m + 1) begin : tdiag
      assign term[m][m] = Gblk[m];
    end
    for (m = 1; m < 16; m = m + 1) begin : touter
      for (j = 0; j < m; j = j + 1) begin : tinner
        and #(2) (term[m][j], PPROD[m-1][j], Gblk[j]);
      end
    end
  endgenerate
 

  wire [0:15] cinterm;
  generate
    for (m = 0; m < 16; m = m + 1) begin : ctm
      and #(2) (cinterm[m], PPROD0[m], cin);
    end
  endgenerate
 
  wire acc [0:15][0:15];
  wire [15:0] cnext; 
  generate
    for (m = 0; m < 16; m = m + 1) begin : cchain
      assign acc[m][0] = term[m][0];
      for (j = 1; j <= m; j = j + 1) begin : cchain_inner
        or #(2) (acc[m][j], acc[m][j-1], term[m][j]);
      end
      or #(2) (cnext[m], acc[m][m], cinterm[m]);
    end
  endgenerate
 
  assign blk_cin[0]    = cin;
  assign blk_cin[15:1] = cnext[14:0];
  assign cout           = cnext[15];
 
endmodule


module cla64_hier(
  input  [63:0] a,
  input  [63:0] b,
  input         cin,
  output [63:0] sum,
  output        cout
);

  // TODO: your hierarchical design goes here.

  wire [15:0] Gblk, Pblk, blk_cin;

  genvar k;
  generate
    for (k = 0; k < 16; k = k + 1) begin : blocks
      cla4 u_cla4 (
        .a    (a[4*k+3:4*k]),
        .b    (b[4*k+3:4*k]),
        .cin  (blk_cin[k]),
        .sum  (sum[4*k+3:4*k]),
        .cout (),
        .Gblk (Gblk[k]),
        .Pblk (Pblk[k])
      );
    end
  endgenerate

  cla_la16 u_la16 (
    .Gblk    (Gblk),
    .Pblk    (Pblk),
    .cin     (cin),
    .blk_cin (blk_cin),
    .cout    (cout)
  );

endmodule
