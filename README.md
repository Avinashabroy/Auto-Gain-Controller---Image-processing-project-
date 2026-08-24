# Auto-Gain-Controller--ISP
Developed a beginner-level AGC image-processing project in Verilog using Vivado. It uses a frame buffer to store 9 pixels, calculates average brightness, accepts a target value, calculates Q8 gain, applies gain with saturation, and verifies the complete design through simulation.
# What is AGC (Auto Gain Controller) 
AGC (Automatic Gain Control) is an ISP feature that automatically adjusts the sensor gain to maintain proper image brightness under different lighting conditions. It analyzes the image brightness and increases or decreases the gain accordingly.
## Example

### Before and After AGC

![AGC Before and After](agc_before_after.png)
## Working Principal
# Step 1: Calculate Average Brightness
Read 9 pixels from the input frame
Add all pixel values
Divide the total sum by the number of pixels
The result represents the average brightness of the frame

Example:
Pixels = 10,20,30,40,50,60,70,80,80 

Sum    = 440

Average = 440 / 9 = 48

# STEP 2: CALCULATE GAIN
Compare the average brightness with the user-defined target value
Gain = Target Brightness / Average Brightness

Example:
Average = 48
Target  = 120
Gain    = 120 / 48 = 2.5

Q8 Gain = Gain × 256
        = 2.5 × 256
       = 640

# STEP 3: FRAME BUFFER
Store the input pixels in the frame buffer during the write phase
After the gain is calculated, read the stored pixels during the read phase
The frame buffer allows the same frame to be processed with the new gain

WRITE:
Pixel input → Frame Buffer

READ:
Frame Buffer → Gain Apply

# This separates pixel storage from pixel processing.
# STEP 4: APPLY GAIN
Read the stored pixels from the frame buffer
Apply the calculated Q8 gain to each pixel
Output = (Pixel × Q8 Gain) / 256
Limit the output to 255 if it exceeds the 8-bit range

Example:
Pixel = 20
Q8    = 640
Output = (20 × 640) / 256  = 50

# Main data flow
Pixel Input
    │
    ▼
Average
    │
    │ avg
    ▼
Gain Controller ◄──── Target Value
    │
    │ q8
    ▼
Frame Buffer
    │
    │ pixel_read
    ▼
Gain Apply
    │
    ▼
Pixel Output
