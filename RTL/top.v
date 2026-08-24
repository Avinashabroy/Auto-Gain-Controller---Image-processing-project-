`timescale 1ns/1ps
module agc_top #(
    parameter TOTAL_PIXEL = 9
)
(
    input        clk,
    input        rst,

    input        pixel_valid,
    input  [7:0] pixel_in,

    input  [7:0] target_value,

    output [7:0] pixel_out
);
 
    // Internal signal

    wire [7:0]  avg;
    wire        avg_valid;
    wire        frame_end;
    wire pixel_out_valid;
    wire [15:0] q8;

    wire [7:0]  pixel_read;

    reg  [3:0]  wrt_addr;
    reg  [3:0]  rd_addr;

    reg         read_enable;
    reg         pixel_read_valid;
    // FSM
localparam STATE_WRITE      = 3'd0;
localparam STATE_WAIT       = 3'd1;
localparam STATE_READ_START = 3'd2;
localparam STATE_READ       = 3'd3;
localparam STATE_DONE       = 3'd4;

reg [2:0] state;
   
    // Module 1: Average calculator

    agc #(
        .TOTAL_PIXEL(TOTAL_PIXEL)
    )
    u_average
    (
        .clk         (clk),
        .rst         (rst),
        .pixel_valid (pixel_valid),
        .pixel_in    (pixel_in),

        .avg         (avg),
        .avg_valid   (avg_valid),
        .frame_end   (frame_end)
    );


    // Module 2: Gain controller

    gain_control dut1
    (
        .clk          (clk),
        .rst          (rst),
        .target_value (target_value),
        .avg          (avg),
        .avg_valid    (avg_valid),
        .q8           (q8)
    );


    
    // Module 3: Frame buffer
  
    frame_buffer u_buffer
    (
        .clk         (clk),
        .rst         (rst),

        .pixel_valid (pixel_valid),
        .pixel_in    (pixel_in),
        .write_addr  (wrt_addr),

        .read_enable (read_enable),
        .read_addr   (rd_addr),
        .pixel_read  (pixel_read)
    );
    
    // Delay read valid by one clock

    always @(posedge clk)
    begin
        if (rst)
            pixel_read_valid <= 1'b0;
        else
            pixel_read_valid <= read_enable;
    end


   
    // Module 4: Gain apply
gain_apply u_gain_apply
(
    .clk             (clk),
    .rst             (rst),

    .pixel_valid     (pixel_read_valid),
    .pixel_in        (pixel_read),
    .q8              (q8),

    .pixel_out       (pixel_out),
    .pixel_out_valid (pixel_out_valid)
);

    // FSM + ADDRESS CONTROL
always @(posedge clk)
begin
    if (rst)
    begin
        state            <= STATE_WRITE;
        wrt_addr         <= 4'd0;
        rd_addr          <= 4'd0;
        read_enable      <= 1'b0;
        pixel_read_valid <= 1'b0;
    end
    else
    begin

        // Delay valid by one clock because RAM read is synchronous
        pixel_read_valid <= read_enable;

        case (state)

            // WRITE FRAME
            STATE_WRITE:
            begin
                read_enable <= 1'b0;

                if (pixel_valid)
                begin
                    if (wrt_addr == TOTAL_PIXEL-1)
                    begin
                        wrt_addr <= 4'd0;
                        state <= STATE_WAIT;
                    end
                    else
                    begin
                        wrt_addr <= wrt_addr + 1'b1;
                    end
                end
            end

            // WAIT FOR GAIN
            STATE_WAIT:
            begin
                read_enable <= 1'b0;

                if (avg_valid)
                begin
                    rd_addr <= 4'd0;
                    state <= STATE_READ_START;
                end
            end

            // START FIRST READ
            STATE_READ_START:
            begin
                read_enable <= 1'b1;

                // IMPORTANT:
                // Keep rd_addr = 0 here.
                // Do NOT increment it.
                state <= STATE_READ;
            end

            // READ REMAINING PIXELS
            STATE_READ:
            begin
                read_enable <= 1'b1;

                if (rd_addr == TOTAL_PIXEL-1)
                begin
                    // Address 8 has been requested
                    state <= STATE_DONE;
                end
                else
                begin
                    rd_addr <= rd_addr + 1'b1;
                end
            end
            // DONE
            STATE_DONE:
            begin
                read_enable <= 1'b0;
                state <= STATE_DONE;
            end

            default:
            begin
                state <= STATE_WRITE;
                wrt_addr <= 4'd0;
                rd_addr <= 4'd0;
                read_enable <= 1'b0;
            end

        endcase
    end
end

endmodule 
