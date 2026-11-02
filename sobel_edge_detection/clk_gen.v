`timescale 1ns / 1ps

//=============================================================================
// STUDENT DESIGN CHALLENGE: Clock Generation & Frequency Synthesis
//=============================================================================
// Target Device: Xilinx Artix-7 XC7A100T-FTG256-1 (EDGE Artix-7 Board)
// Reference Clock: 50.000 MHz LVCMOS33 Oscillator on Pin N11 (sys_clk)
//
// PROBLEM SPECIFICATION:
// The development board supplies only a single 50 MHz reference clock.
// However, this real-time video processing pipeline contains multiple hardware
// subsystems (camera sensor, digital video timing, frame buffer, HDMI PHY)
// that require specific operating clocks.
//
// YOU MUST:
// 1. Analyze the subsystems across this project to determine:
//    - How many distinct clock domains are required in total?
//    - What exact frequency must each clock run at to meet its standard?
//    - What are the phase, duty-cycle, and harmonic ratio requirements?
// 2. Declare the required output clock ports on this module.
// 3. Design and configure the Xilinx 7-Series MMCM (MMCME2_ADV primitive)
//    or Clocking Wizard:
//    - Set DIVCLK_DIVIDE and CLKFBOUT_MULT_F so that the MMCM VCO operates
//      within the required Artix-7 -1 speed grade range:
//          600.000 MHz <= F_VCO <= 1200.000 MHz
//    - Calculate and configure CLKOUTx_DIVIDE parameters for each clock.
// 4. Buffer the feedback clock and all output clocks through global clock
//    buffers (BUFG) to avoid high skew and hold violations.
// 5. Connect the `locked` output to indicate when all clocks are stable.
//=============================================================================

module clk_gen (
    input  wire clk_in,
    input  wire reset,
    output wire locked
    
    output wire clk_display,
    output wire clk_serial,
    output wire cam_xclk_gen,
    // ========================================================================
    // [STUDENT TODO]: Declare your required clock output ports below!
    // Example:
    // output wire your_clk_1,
    // output wire your_clk_2,
    // ...
    // ========================================================================
);

    // ========================================================================
    // [STUDENT TODO]: Implement your Clock Generation Module here!
    //
    // Guidelines:
    // 1. Buffer the incoming clk_in with an IBUF primitive.
    // 2. Instantiate MMCME2_ADV with your calculated VCO mult and dividers.
    // 3. Route CLKFBOUT through a BUFG and back to CLKFBIN.
    // 4. Route each CLKOUTx through a BUFG to drive internal clock distribution.
    // ========================================================================

 // =====================================================
    // MMCM 1:
    // 50 MHz input -> 1000 MHz VCO
    // 1000 / 40 = 25 MHz display clock
    // 1000 / 8  = 125 MHz serializer clock
    // =====================================================

    wire clkfb1;
    wire clkfb1_buf;

    wire clk_display_mmcm;
    wire clk_serial_mmcm;
    wire locked1;

    MMCME2_ADV #(
        .BANDWIDTH("OPTIMIZED"),
        .CLKIN1_PERIOD(20.0),
        .DIVCLK_DIVIDE(1),
        .CLKFBOUT_MULT_F(20.0),

        .CLKOUT0_DIVIDE_F(40.0),
        .CLKOUT1_DIVIDE(8),

        .STARTUP_WAIT("FALSE")
    ) mmcm_display (
        .CLKIN1(clk_in),
        .CLKIN2(1'b0),
        .CLKINSEL(1'b1),

        .CLKFBIN(clkfb1_buf),
        .CLKFBOUT(clkfb1),

        .CLKOUT0(clk_display_mmcm),
        .CLKOUT1(clk_serial_mmcm),

        .RST(reset),
        .PWRDWN(1'b0),

        .LOCKED(locked1),

        .DADDR(7'b0),
        .DCLK(1'b0),
        .DEN(1'b0),
        .DI(16'b0),
        .DWE(1'b0),

        .PSCLK(1'b0),
        .PSEN(1'b0),
        .PSINCDEC(1'b0)
    );

    BUFG fb1_buffer (
        .I(clkfb1),
        .O(clkfb1_buf)
    );

    BUFG display_buffer (
        .I(clk_display_mmcm),
        .O(clk_display)
    );

    BUFG serial_buffer (
        .I(clk_serial_mmcm),
        .O(clk_serial)
    );


    // =====================================================
    // MMCM 2:
    // 50 MHz input -> 600 MHz VCO
    // 600 / 25 = 24 MHz camera XCLK
    // =====================================================

    wire clkfb2;
    wire clkfb2_buf;

    wire cam_xclk_mmcm;
    wire locked2;

    MMCME2_ADV #(
        .BANDWIDTH("OPTIMIZED"),
        .CLKIN1_PERIOD(20.0),
        .DIVCLK_DIVIDE(1),
        .CLKFBOUT_MULT_F(12.0),

        .CLKOUT0_DIVIDE_F(25.0),

        .STARTUP_WAIT("FALSE")
    ) mmcm_camera (
        .CLKIN1(clk_in),
        .CLKIN2(1'b0),
        .CLKINSEL(1'b1),

        .CLKFBIN(clkfb2_buf),
        .CLKFBOUT(clkfb2),

        .CLKOUT0(cam_xclk_mmcm),

        .RST(reset),
        .PWRDWN(1'b0),

        .LOCKED(locked2),

        .DADDR(7'b0),
        .DCLK(1'b0),
        .DEN(1'b0),
        .DI(16'b0),
        .DWE(1'b0),

        .PSCLK(1'b0),
        .PSEN(1'b0),
        .PSINCDEC(1'b0)
    );

    BUFG fb2_buffer (
        .I(clkfb2),
        .O(clkfb2_buf)
    );

    BUFG camera_buffer (
        .I(cam_xclk_mmcm),
        .O(cam_xclk_gen)
    );

    // Both MMCMs must be locked.
    assign locked = locked1 & locked2;

endmodule
