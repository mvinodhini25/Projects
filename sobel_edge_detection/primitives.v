
`timescale 1ns/1ps

//============================================================
// 1. BUFG - Global Clock Buffer
//============================================================
module BUFG (
    input  wire I,
    output wire O
);
    assign O = I;
endmodule


//============================================================
// 2. OBUFDS - Differential Output Buffer
//============================================================
module OBUFDS (
    input  wire I,
    output wire O,
    output wire OB
);
    assign O  = I;
    assign OB = ~I;
endmodule


//============================================================
// 3. ODDR - Double Data Rate Output
//============================================================
module ODDR #(
    parameter DDR_CLK_EDGE = "OPPOSITE_EDGE",
    parameter INIT         = 1'b0,
    parameter SRTYPE       = "SYNC"
) (
    input  wire C,
    input  wire CE,
    input  wire D1,
    input  wire D2,
    input  wire R,
    input  wire S,
    output reg  Q
);

    initial Q = INIT;

    always @(posedge C or posedge R or posedge S) begin
        if (R)
            Q <= 1'b0;
        else if (S)
            Q <= 1'b1;
        else if (CE)
            Q <= D1;
    end

    always @(negedge C or posedge R or posedge S) begin
        if (R)
            Q <= 1'b0;
        else if (S)
            Q <= 1'b1;
        else if (CE)
            Q <= D2;
    end

endmodule


//============================================================
// 4. MMCME2_ADV - Simplified MMCM Simulation Model
//============================================================
module MMCME2_ADV #(
    parameter BANDWIDTH           = "OPTIMIZED",
    parameter real CLKIN1_PERIOD  = 0.0,
    parameter integer DIVCLK_DIVIDE = 1,
    parameter real CLKFBOUT_MULT_F = 5.0,
    parameter real CLKOUT0_DIVIDE_F = 1.0,
    parameter integer CLKOUT1_DIVIDE = 1,
    parameter STARTUP_WAIT        = "FALSE"
) (
    input  wire CLKIN1,
    input  wire CLKIN2,
    input  wire CLKINSEL,
    input  wire CLKFBIN,
    input  wire RST,
    input  wire PWRDWN,

    output wire CLKFBOUT,
    output wire CLKOUT0,
    output wire CLKOUT1,
    output wire CLKOUT2,
    output wire CLKOUT3,
    output wire CLKOUT4,
    output wire CLKOUT5,
    output wire CLKOUT6,
    output wire LOCKED,

    input  wire [6:0] DADDR,
    input  wire DCLK,
    input  wire DEN,
    input  wire [15:0] DI,
    input  wire DWE,
    output wire [15:0] DO,
    output wire DRDY,

    input  wire PSCLK,
    input  wire PSEN,
    input  wire PSINCDEC,
    output wire PSDONE
);

    // Simulation-only pass-through clock model.
    // Actual MMCM frequency multiplication/division
    // is NOT modeled here.

    assign CLKFBOUT = CLKIN1;

    assign CLKOUT0 = CLKIN1;
    assign CLKOUT1 = CLKIN1;
    assign CLKOUT2 = CLKIN1;
    assign CLKOUT3 = CLKIN1;
    assign CLKOUT4 = CLKIN1;
    assign CLKOUT5 = CLKIN1;
    assign CLKOUT6 = CLKIN1;

    assign LOCKED = ~RST & ~PWRDWN;

    assign DO     = 16'b0;
    assign DRDY   = 1'b0;
    assign PSDONE = 1'b0;

endmodule

