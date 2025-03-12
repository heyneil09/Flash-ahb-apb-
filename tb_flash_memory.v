module tb_flash_memory;
    logic clk, rst_n;
    logic [31:0] haddr, hwdata, hrdata;
    logic hwrite, hsel, hready, hresp;
    logic [31:0] paddr, pwdata, prdata;
    logic pwrite, psel, penable, pready;
    logic flash_we, flash_erase;
    logic [31:0] flash_addr;
    wire [31:0] flash_data;

    flash_memory uut (
        .clk(clk),
        .rst_n(rst_n),
        .haddr(haddr), .hwdata(hwdata), .hwrite(hwrite), .hsel(hsel), .hready(hready), .hrdata(hrdata), .hresp(hresp),
        .paddr(paddr), .pwdata(pwdata), .pwrite(pwrite), .psel(psel), .penable(penable), .prdata(prdata), .pready(pready),
        .flash_we(flash_we), .flash_erase(flash_erase), .flash_addr(flash_addr), .flash_data(flash_data)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    task ahb_write(input [31:0] addr, input [31:0] data);
        hsel = 1; hwrite = 1; hready = 1;
        haddr = addr; hwdata = data;
        #10 hwrite = 0;
    endtask

    task ahb_read(input [31:0] addr);
        hsel = 1; hwrite = 0; hready = 1;
        haddr = addr;
        #10 $display("AHB Read Data at %h: %h", addr, hrdata);
    endtask

    task apb_write(input [31:0] addr, input [31:0] data);
        psel = 1; penable = 1; pwrite = 1;
        paddr = addr; pwdata = data;
        #10 pwrite = 0;
    endtask

    task apb_read(input [31:0] addr);
        psel = 1; penable = 1; pwrite = 0;
        paddr = addr;
        #10 $display("APB Read Data at %h: %h", addr, prdata);
    endtask

    initial begin
        rst_n = 0;
        #10 rst_n = 1;
        ahb_write(32'h00000010, 32'hDEADBEEF);
        ahb_read(32'h00000010);
        apb_write(32'h00000020, 32'hCAFEBABE);
        apb_read(32'h00000020);
        #50 $finish;
    end
endmodule
