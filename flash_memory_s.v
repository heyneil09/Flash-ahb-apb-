module flash_memory_s (
    input logic clk, reset,
    input logic apb_sel, apb_write,
    input logic [7:0] apb_addr,
    input logic [31:0] apb_wdata,
    output logic [31:0] apb_rdata
);
    logic [31:0] flash_mem [0:255]; // Simple 256-word flash memory

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            apb_rdata <= 32'b0;
        end 
        else if (apb_sel) begin
            if (apb_write) 
                flash_mem[apb_addr] <= apb_wdata;  // Write operation
            else 
                apb_rdata <= flash_mem[apb_addr];  // Read operation
        end
    end
endmodule
