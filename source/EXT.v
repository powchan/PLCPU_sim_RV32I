`include "ctrl_encode_def.v"
module EXT( 
    input	[11:0]			iimm, //instr[31:20], 12 bits
	input	[11:0]			simm, //instr[31:25, 11:7], 12 bits
	input	[19:0]			uimm, // U type
	input	[5:0]			EXTOp,

	output	reg [31:0] 	    immout
	);

always  @(*)
	 case (EXTOp)
		`EXT_CTRL_ITYPE:	immout <= {{20{iimm[11]}}, iimm[11:0]};
		`EXT_CTRL_STYPE:	immout <= {{20{simm[11]}}, simm[11:0]};
		`EXT_CTRL_UTYPE:	immout <= {uimm[19:0], 12'b0};     //???????????12??0
		default:	        immout <= 32'b0;
	 endcase
       
endmodule
