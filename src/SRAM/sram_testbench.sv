module sram_testbench ();
    parameter WIDTH = 32;
    parameter DEPTH = 256;

    reg clk;
    reg reset;
    reg write_enable;
    reg [$clog2(DEPTH)-1:0] addr;
    reg signed [WIDTH-1:0] write_word;
    wire signed [WIDTH-1:0] word;

    sram #(
        .WIDTH(WIDTH),
        .DEPTH(DEPTH),
        .RESET_VALUE(0)
    ) uut (
        .clk(clk),
        .write_enable(write_enable),
        .addr(addr),
        .write_word(write_word),
        .word(word)
    );

    initial begin
        write_enable = 0;
        addr = 0;
        write_word = 0;
        reset = 1;

        // Test writing to SRAM
        #10;
        reset = 0;
        write_enable = 1;
        addr = 5;
        write_word = 42; // Write value 42 to address 5

        #10;
        // Test reading from SRAM
        write_enable = 0;
        addr = 5; // Read from address 5

        #10;
        addr = 0; // Read from address 0

        #10;
        // Test reading from SRAM
        addr = 5; // Read from address 5
        #10;

        $finish;
    end

    always begin
        clk = 1;
        forever #5 clk = ~clk; // 5 ns clock period
    end

endmodule