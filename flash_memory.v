module flash_memory (
    input logic clk,
    input logic rst_n,
    // AHB Interface
    input logic [31:0] haddr,
    input logic [31:0] hwdata,
    input logic hwrite,
    input logic hsel,
    input logic hready,
    output logic [31:0] hrdata,
    output logic hresp,
    // APB Interface
    input logic [31:0] paddr,
    input logic [31:0] pwdata,
    input logic pwrite,
    input logic psel,
    input logic penable,
    output logic [31:0] prdata,
    output logic pready,
    // Flash Control
    output logic flash_we,
    output logic flash_erase,
    output logic [31:0] flash_addr,
    inout  logic [31:0] flash_data
);

    // Internal Registers
    logic [31:0] flash_mem [0:255];  // 256 x 32-bit memory
    logic [31:0] flash_reg;

    // AHB Read/Write Logic
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            hrdata <= 32'b0;
            hresp  <= 1'b0;
        end else if (hsel && hready) begin
            if (hwrite) begin
                flash_mem[haddr[7:0]] <= hwdata;
            end else begin
                hrdata <= flash_mem[haddr[7:0]];
            end
        end
    end

    // APB Register Access
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            prdata <= 32'b0;
            pready <= 1'b0;
        end else if (psel && penable) begin
            if (pwrite) begin
                flash_reg <= pwdata;
            end else begin
                prdata <= flash_reg;
            end
        end
    end

    // Flash Control Signals
    assign flash_we = pwrite & psel;
    assign flash_erase = (paddr == 32'hFFFF0000) & pwrite;
    assign flash_addr = haddr;
    assign flash_data = (hwrite) ? hwdata : 32'bz;

endmodule

// AHB to APB Bridge (Master-Slave Conversion)
module ahb_apb_bridge (
    input logic clk,
    input logic rst_n,
    // AHB Interface
    input logic [31:0] haddr,
    input logic [31:0] hwdata,
    input logic hwrite,
    input logic hsel,
    input logic hready,
    output logic [31:0] hrdata,
    output logic hresp,
    // APB Interface
    output logic [31:0] paddr,
    output logic [31:0] pwdata,
    output logic pwrite,
    output logic psel,
    output logic penable,
    input logic [31:0] prdata,
    input logic pready
);

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            paddr   <= 32'b0;
            pwdata  <= 32'b0;
            pwrite  <= 1'b0;
            psel    <= 1'b0;
            penable <= 1'b0;
        end else if (hsel && hready) begin
            paddr   <= haddr;
            pwdata  <= hwdata;
            pwrite  <= hwrite;
            psel    <= 1'b1;
            penable <= 1'b1;
        end else begin
            psel    <= 1'b0;
            penable <= 1'b0;
        end
    end

    assign hrdata = prdata;
    assign hresp = 1'b0; // OKAY response

endmodule
