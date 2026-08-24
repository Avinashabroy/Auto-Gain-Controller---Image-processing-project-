module frame_buffer #(
    parameter TOTAL_PIXEL = 9
)
(
    input        clk,
    input        rst,

    input        pixel_valid,
    input  [7:0] pixel_in,

    input  [3:0] write_addr,

    input        read_enable,
    input  [3:0] read_addr,

    output reg [7:0] pixel_read
);

    reg [7:0] mem [0:TOTAL_PIXEL-1];

    // Write pixel into memory
    always @(posedge clk)
    begin
        if (rst)
        begin
            // no need to clear memory
        end
        else if (pixel_valid)
        begin
            mem[write_addr] <= pixel_in;
        end
    end

    // Read pixel from memory
    always @(posedge clk)
    begin
        if (rst)
        begin
            pixel_read <= 8'd0;
        end
        else if (read_enable)
        begin
            pixel_read <= mem[read_addr];
        end
    end

endmodule
