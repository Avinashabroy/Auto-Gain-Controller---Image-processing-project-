module agc #(parameter TOTAL_PIXEL = 9)
(
    input clk,
    input rst,
    input pixel_valid,
    input [7:0] pixel_in,
    output reg [7:0] avg,
    output reg avg_valid,
    output wire frame_end
);

reg [15:0] sum;
reg [7:0] count;
wire   frame_start;

always @(posedge clk)
begin
    if (rst)
    begin
        sum   <= 0;
        count <= 0;
        avg   <= 0;
    end
    else
    begin
        // New frame
        if (frame_start)
        begin
            sum   <= pixel_in;
            count <= 1;
        end

        // Normal pixel
        else if (pixel_valid && !frame_end)
        begin
            sum   <= sum + pixel_in;
            count <= count + 1;
        end

        // Last pixel of frame
        else if (pixel_valid && frame_end)
        begin
            sum   <= sum + pixel_in;
            count <= count + 1;

            // Include the LAST pixel
            avg <= (sum + pixel_in) / (count + 1);
            avg_valid <= 1'b1;
        end
      else 
        begin
    avg_valid <= 1'b0;
       end
    end
end
assign frame_start = (count == 0);
assign frame_end   = (count == TOTAL_PIXEL-1);
endmodule
