/*
	Copyright 2020 Mohamed Shalan

	Author: Mohamed Shalan (mshalan@aucegypt.edu)

	Licensed under the Apache License, Version 2.0 (the "License");
	you may not use this file except in compliance with the License.
	You may obtain a copy of the License at

	    http://www.apache.org/licenses/LICENSE-2.0

	Unless required by applicable law or agreed to in writing, software
	distributed under the License is distributed on an "AS IS" BASIS,
	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	See the License for the specific language governing permissions and
	limitations under the License.

*/

/* THIS FILE IS GENERATED, DO NOT EDIT */

`timescale			1ns/1ps
`default_nettype	none

module MS_WDT32_APB (
`ifdef USE_POWER_PINS
	inout VPWR,
	inout VGND,
`endif
	input wire          PCLK,
                                        input wire          PRESETn,
                                        input wire          PWRITE,
                                        input wire [31:0]   PWDATA,
                                        input wire [31:0]   PADDR,
                                        input wire          PENABLE,
                                        input wire          PSEL,
                                        output wire         PREADY,
                                        output wire [31:0]  PRDATA,
                                        output wire         IRQ

);

	localparam	timer_REG_OFFSET = 16'h0000;
	localparam	load_REG_OFFSET = 16'h0004;
	localparam	control_REG_OFFSET = 16'h0008;
	localparam	IM_REG_OFFSET = 16'hFF00;
	localparam	MIS_REG_OFFSET = 16'hFF04;
	localparam	RIS_REG_OFFSET = 16'hFF08;
	localparam	IC_REG_OFFSET = 16'hFF0C;

        reg [0:0] GCLK_REG;
        wire clk_g;
        wire clk_gated_en = GCLK_REG[0];

	`ifdef FPGA
		wire clk = PCLK;
	`else
		(* keep *) sky130_fd_sc_hd__dlclkp_4 clk_gate(
		`ifdef USE_POWER_PINS 
			.VPWR(VPWR), 
			.VGND(VGND), 
			.VNB(VGND),
			.VPB(VPWR),
		`endif
			.GCLK(clk_g), 
			.GATE(clk_gated_en), 
			.CLK(PCLK)
			);
			
		wire		clk = clk_g;
	`endif
	wire		rst_n = PRESETn;


	wire		apb_valid   = PSEL & PENABLE;
                                        wire		apb_we	    = PWRITE & apb_valid;
                                        wire		apb_re	    = ~PWRITE & apb_valid;

	wire [32-1:0]	WDTMR;
	wire [32-1:0]	WDTLOAD;
	wire [1-1:0]	WDTTO;
	wire [1-1:0]	WDTEN;

	// Register Definitions
	wire [32-1:0]	timer_WIRE;
	assign	timer_WIRE = WDTMR;

	reg [31:0]	load_REG;
	assign	WDTLOAD = load_REG;
	always @(posedge PCLK or negedge PRESETn) if(~PRESETn) load_REG <= 0;
                                        else if(apb_we & (PADDR[16-1:0]==load_REG_OFFSET))
                                            load_REG <= PWDATA[32-1:0];

	reg [0:0]	control_REG;
	assign	WDTEN = control_REG;
	always @(posedge PCLK or negedge PRESETn) if(~PRESETn) control_REG <= 0;
                                        else if(apb_we & (PADDR[16-1:0]==control_REG_OFFSET))
                                            control_REG <= PWDATA[1-1:0];

	localparam	GCLK_REG_OFFSET = 16'hFF10;
	always @(posedge PCLK or negedge PRESETn) if(~PRESETn) GCLK_REG <= 0;
                                        else if(apb_we & (PADDR[16-1:0]==GCLK_REG_OFFSET))
                                            GCLK_REG <= PWDATA[1-1:0];

	reg [0:0] IM_REG;
	reg [0:0] IC_REG;
	reg [0:0] RIS_REG;

	wire[1-1:0]      MIS_REG	= RIS_REG & IM_REG;
	always @(posedge PCLK or negedge PRESETn) if(~PRESETn) IM_REG <= 0;
                                        else if(apb_we & (PADDR[16-1:0]==IM_REG_OFFSET))
                                            IM_REG <= PWDATA[1-1:0];
	always @(posedge PCLK or negedge PRESETn) if(~PRESETn) IC_REG <= 1'b0;
                                        else if(apb_we & (PADDR[16-1:0]==IC_REG_OFFSET))
                                            IC_REG <= PWDATA[1-1:0];
                                        else
                                            IC_REG <= 1'd0;

	wire [0:0] wdtto = WDTTO;


	integer _i_;
	always @(posedge PCLK or negedge PRESETn) if(~PRESETn) RIS_REG <= 0; else begin
		for(_i_ = 0; _i_ < 1; _i_ = _i_ + 1) begin
			if(IC_REG[_i_]) RIS_REG[_i_] <= 1'b0; else if(wdtto[_i_ - 0] == 1'b1) RIS_REG[_i_] <= 1'b1;
		end
	end

	assign IRQ = |MIS_REG;

	MS_WDT32 instance_to_wrap (
		.clk(clk),
		.rst_n(rst_n),
		.WDTMR(WDTMR),
		.WDTLOAD(WDTLOAD),
		.WDTTO(WDTTO),
		.WDTEN(WDTEN)
	);

	assign	PRDATA = 
			(PADDR[16-1:0] == timer_REG_OFFSET)	? timer_WIRE :
			(PADDR[16-1:0] == load_REG_OFFSET)	? load_REG :
			(PADDR[16-1:0] == control_REG_OFFSET)	? control_REG :
			(PADDR[16-1:0] == IM_REG_OFFSET)	? IM_REG :
			(PADDR[16-1:0] == MIS_REG_OFFSET)	? MIS_REG :
			(PADDR[16-1:0] == RIS_REG_OFFSET)	? RIS_REG :
			(PADDR[16-1:0] == IC_REG_OFFSET)	? IC_REG :
			(PADDR[16-1:0] == GCLK_REG_OFFSET)	? GCLK_REG :
			32'hDEADBEEF;

	assign	PREADY = 1'b1;

endmodule
