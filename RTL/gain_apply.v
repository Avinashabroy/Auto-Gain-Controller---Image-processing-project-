`timescale 1ns/1ps

module gain_apply (
    input        clk,
    input        rst,

    input        pixel_valid,
    input  [7:0] pixel_in,
    input  [15:0] q8,

    output reg [7:0] pixel_out,
    output reg       pixel_out_valid
);

    reg [23:0] mult;

    always @(posedge clk)
    begin
        if (rst)
        begin
            pixel_out       <= 8'd0;
            pixel_out_valid <= 1'b0;
            mult            <= 24'd0;
        end
        else
        begin
            // Default: output is not valid
            pixel_out_valid <= 1'b0;

            if (pixel_valid)
            begin
                mult = pixel_in * q8;

                if ((mult >> 8) > 255)
                    pixel_out <= 8'd255;
                else
                    pixel_out <= mult >> 8;

                pixel_out_valid <= 1'b1;
            end
        end
    end

endmodule
