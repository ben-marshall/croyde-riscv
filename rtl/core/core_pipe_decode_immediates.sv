
//
// module: core_pipe_decode_immediates
//
//  Purely combinatorial module for decoding instruction immediates,
//  particularly from the fiddly 16-bit encodings.
//
module core_pipe_decode_immediates (

input  wire [31:0] instr        ,   // Input encoded instruction.

output wire [31:0] imm32_i      ,
output wire [11:0] imm_csr_addr ,
output wire [ 4:0] imm_csr_mask ,
output wire [31:0] imm32_s      ,
output wire [31:0] imm32_b      ,
output wire [31:0] imm32_u      ,
output wire [31:0] imm32_j      ,
output wire [31:0] imm_addi16sp ,
output wire [31:0] imm_addi4spn ,
output wire [31:0] imm_c_lsw    ,
output wire [31:0] imm_c_addi   ,
output wire [31:0] imm_c_lui    ,
output wire [31:0] imm_c_lwsp   ,
output wire [31:0] imm_c_swsp   ,
output wire [31:0] imm_c_j      ,
output wire [31:0] imm_c_bz      

);

assign imm32_i = {{20{instr[31]}}, instr[31:20]};

assign imm_csr_addr = instr[31:20];

assign imm_csr_mask = instr[19:15];

assign imm32_s = {{20{instr[31]}}, instr[31:25], instr[11:7]};

assign imm32_b = 
    {{19{instr[31]}},instr[31],instr[7],instr[30:25],instr[11:8],1'b0};

assign imm32_u = {instr[31:12], 12'b0};

assign imm32_j = 
    {{11{instr[31]}},instr[31],instr[19:12],instr[20],instr[30:21],1'b0};

assign imm_addi16sp = {
    {23{instr[12]}},instr[4:3],instr[5],instr[2],instr[6],4'b0};

assign imm_addi4spn = {
    22'b0, instr[10:7],instr[12:11],instr[5],instr[6],2'b00};

assign imm_c_lsw = {
    25'b0,instr[5],instr[12:10], instr[6], 2'b00};

assign imm_c_addi = {
    {27{instr[12]}}, instr[6:2]};

assign imm_c_lui  = {
    {15{instr[12]}}, instr[6:2],12'b0};

assign imm_c_lwsp = {
    24'b0,instr[3:2], instr[12], instr[6:4], 2'b00};

assign imm_c_swsp = {
    24'b0,instr[8:7], instr[12:9], 2'b0};

assign imm_c_j = {
    {21{instr[12]}}, // 11 - sign extended
    instr[8], // 10
    instr[10:9], // 9:8
    instr[6], // 7
    instr[7], // 6
    instr[2], // 5
    instr[11], // 4
    instr[5:3], // 3:1,
    1'b00
};

assign imm_c_bz = {
    {24{instr[12]}},instr[6:5],instr[2],instr[11:10],instr[4:3],1'b0
};

endmodule
