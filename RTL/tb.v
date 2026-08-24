`timescale 1ns/1ps

module tb_agc;

    reg        clk;
    reg        rst;
    reg        pixel_valid;
    reg [7:0]  pixel_in;
    reg [7:0]  target_value;

    wire [7:0] pixel_out;

    // DUT
    agc_top dut (
        .clk          (clk),
        .rst          (rst),
        .pixel_valid  (pixel_valid),
        .pixel_in     (pixel_in),
        .target_value (target_value),
        .pixel_out    (pixel_out)
    );

    // Print only updated AGC pixels
always @(posedge clk)
begin
    if (dut.u_gain_apply.pixel_out_valid)
    begin
        $display("UPDATED PIXEL = %0d", pixel_out);
    end
end
    // Clock = 100 MHz
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end


    // Send one pixel
    task send_pixel(input [7:0] pixel);
    begin
        @(negedge clk);

        pixel_in    = pixel;
        pixel_valid = 1'b1;

        @(negedge clk);

        pixel_valid = 1'b0;
    end
    endtask


    // =====================================================
    // TEST
    // =====================================================

    initial begin

        rst         = 1'b1;
        pixel_valid = 1'b0;
        pixel_in    = 8'd0;
        target_value = 8'd120;


        // Reset
        #20;
        rst = 1'b0;


   
        // =================================================
        // FRAME 1
        // =================================================

        $display("--------------------------------");
        $display("FRAME 1");
        $display("--------------------------------");

        send_pixel(10);
        send_pixel(20);
        send_pixel(30);
        send_pixel(40);
        send_pixel(50);
        send_pixel(60);
        send_pixel(70);
        send_pixel(80);
        send_pixel(80);


        // Wait for AGC pipeline to finish
        #200;


        $display("--------------------------------");
        $display("FRAME 1 COMPLETE");
        $display("--------------------------------");


        $finish;

    end

endmodule
