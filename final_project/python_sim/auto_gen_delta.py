import math
import numpy as np
import matplotlib.pyplot as plt
from matplotlib.widgets import Slider

w = 90 # pixel num width 
h = 120 # pixel num height

real_width = 60 #pixel pattern width will relate to real world's 60(cm) (with respect to width)
pixel_w = real_width/w 

v = 34000    # sound speed (cm/s)
fs = 50000   # sampling rate (1/s)

n_microphone = 16
d = 10 # microphone distance (cm)

#pixel is at 50 cm far, create the relevant pixel array and microphone array 
distance = 40
pixel_array = [[np.array([pixel_w*(i-(w-1)/2),pixel_w*(j-(h-1)/2),distance]) for i in range (0,w)] for j in range (0,h)]
microphone_array = [[np.array([d*(i-1.5),d*(j-1.5),0]) for i in range (0,4)] for j in range (0,4)]

#trendline of the margin of points with same delta value: center of (0,0): (25,15). This needs trial and error
x= np.linspace(0,699,500)
center_x_00 = 37
center_y_00 = 21

correspond_x = int(abs(center_x_00 - h/2))
correspond_y = int(abs(center_y_00 - w/2))

# Create the figure and the line that we will manipulate
fig, ax = plt.subplots()

data = [[round(fs*np.linalg.norm(pixel_array[i][j] - microphone_array[0][0])/v) for i in range (0,h)]for j in range(0,w)]

# maps the radius corresponding to the delta value. This requires trial and error.
radius_map= [25]

# range of delta
delta_min = min([min(r) for r in data])
delta_max = max([max(r) for r in data])

print(delta_min)
print(delta_max)
for i in radius_map:
    temp = center_y_00+ np.sqrt(i**2-(x-center_x_00)**2)
    plt.plot(x, temp)

# shifting of pixels of contingent microphone: 10 (x and y should be equal)
shift_x = 15
shift_y = 16
y12 = center_y_00 + np.sqrt(radius_map[0]**2-(x-shift_x-center_x_00)**2)
y21 = center_y_00 + shift_y + np.sqrt(radius_map[0]**2-(x-center_x_00)**2)
plt.plot(x, y12)
plt.plot(x, y21)

# draw the map and the color bar on the side
temp = ax.imshow(data, interpolation ='none', aspect = 'auto')
bar = plt.colorbar(temp)
fig.subplots_adjust(left=0.25, bottom=0.25)

# Make a horizontally oriented slider to change the microphone in the x direction
ax_x = fig.add_axes([0.25, 0.1, 0.65, 0.03])
x_slider = Slider(
    ax=ax_x,
    label='x',
    valmin=0,
    valmax=3,
    valinit=0,
    valstep=1,
)

# Make a vertically oriented slider to change the microphone in the y direction
ax_y = fig.add_axes([0.1, 0.25, 0.0225, 0.63])
y_slider = Slider(
    ax=ax_y,
    label="y",
    valmin=0,
    valmax=3,
    valinit=0,
    valstep=1,
    orientation="vertical"
)

def update(val):
    #update the microphone pattern when the slider changes value
    temp = [[round(fs*np.linalg.norm(pixel_array[i][j] - microphone_array[x_slider.val][y_slider.val])/v) for i in range (0,h)]for j in range(0,w)]
    ax.imshow(temp, interpolation ='none', aspect = 'auto')
    fig.canvas.draw_idle()

x_slider.on_changed(update)
y_slider.on_changed(update)

plt.show()

def bindigits(n, bits):
    s = bin(n & int("1"*bits, 2))[2:]
    return ("{0:0>%s}" % (bits)).format(s)

real_x = math.floor(math.log2(h/2))+1
real_y = math.floor(math.log2(w/2))+1
difference_data = math.floor(math.log2(delta_max-delta_min)) 
num_data = (h-center_x_00)*(w-center_y_00)-1
iterate_y = (w-center_y_00)
delta_max_bit = math.floor(math.log2(delta_max))

# automate the verilog code output
counter = 0
with open("datafile.sv", "w") as f:
    f.write("//Author: Jerry Chang\n")
    f.write("//This code is generated automatically by python. Please make sure all parameters are correct!\n")
    f.write("//parameter used in this file: pixel: " + str(w) + "*" + str(h) + ", distance=" + str(distance) + " ,real width=" + str(real_width) + " \n")
    f.write("module Coordinate_generator(\n")
    f.write("    input signed [$clog2(`PIXEL_COLUMN)-1:0] p_x,\n")
    f.write("    input signed [$clog2(`PIXEL_ROW)-1:0] p_y,\n")
    f.write("    output signed [" + str(real_x) + ":0] real_x[15:0],\n")
    f.write("    output signed [" + str(real_y) + ":0] real_y[15:0]\n")
    f.write(");\n")
    f.write("    logic signed [$clog2(`PIXEL_COLUMN)-1:0] temp_x;\n")
    f.write("    logic signed [$clog2(`PIXEL_ROW)-1:0] temp_y;\n")
    f.write("    assign temp_x = (p_x==-" + str(int(h/2)) + ") ? p_x+1 : p_x;\n")
    f.write("    assign temp_y = (p_y==-" + str(int(w/2)) + ") ? p_y+1 : p_y;\n")
    f.write("    genvar idx;\n")
    f.write("    generate\n")
    f.write("        for(idx=0; idx<4; idx=idx+1) begin: Geny1\n")
    f.write("            assign real_y[idx] = temp_y + " + str(correspond_y) + ";\n")
    f.write("        end\n")
    f.write("        for(idx=4; idx<8; idx=idx+1) begin: Geny2\n")
    f.write("            assign real_y[idx] = temp_y + " + str(correspond_y-shift_y) + ";\n")
    f.write("        end\n")
    f.write("        for(idx=8; idx<12; idx=idx+1) begin: Geny3\n")
    f.write("            assign real_y[idx] = temp_y - " + str(correspond_y-shift_y) + ";\n")
    f.write("        end\n")
    f.write("        for(idx=12; idx<16; idx=idx+1) begin: Geny4\n")
    f.write("            assign real_y[idx] = temp_y - " + str(correspond_y) + ";\n")
    f.write("        end\n")
    f.write("        for(idx=0; idx<16; idx=idx+4) begin: Genx1\n")
    f.write("            assign real_x[idx] = temp_x + " + str(correspond_x) + ";\n")
    f.write("        end\n")
    f.write("        for(idx=1; idx<16; idx=idx+4) begin: Genx2\n")
    f.write("            assign real_x[idx] = temp_x + " + str(correspond_x-shift_x) + ";\n")
    f.write("        end\n")
    f.write("        for(idx=2; idx<16; idx=idx+4) begin: Genx3\n")
    f.write("            assign real_x[idx] = temp_x - " + str(correspond_x-shift_x) + ";\n")
    f.write("        end\n")
    f.write("        for(idx=3; idx<16; idx=idx+4) begin: Genx4\n")
    f.write("            assign real_x[idx] = temp_x - " + str(correspond_x) + ";\n")
    f.write("        end\n")
    f.write("    endgenerate\n")
    f.write("endmodule\n\n")
    f.write("module abs_X(\n")
    f.write("    input signed [" + str(real_x) +":0] x,\n")
    f.write("    output ["+ str(real_x) +":0] abs_real_x\n")
    f.write(");\n")
    f.write("    assign abs_real_x = x[" + str(real_x) + "] ? -x : x;\n")
    f.write("endmodule\n\n")
    f.write("module abs_Y(\n")
    f.write("    input signed [" + str(real_y) +":0] y,\n")
    f.write("    output ["+ str(real_y) +":0] abs_real_y\n")
    f.write(");\n")
    f.write("    assign abs_real_y = y[" + str(real_y) + "] ? -y : y;\n")
    f.write("endmodule\n\n")
    f.write("module Delta_generator (\n")
    f.write("    input signed [$clog2(`PIXEL_COLUMN)-1:0] p_x,\n")
    f.write("    input signed [$clog2(`PIXEL_ROW)-1:0] p_y,\n")
    f.write("    output [" + str(delta_max_bit) + ":0] delta[15:0]\n")
    f.write(");\n")
    f.write("    logic signed [" + str(real_x) +":0] real_x[15:0];\n")
    f.write("    logic signed [" + str(real_y) +":0] real_y[15:0];\n")
    f.write("    logic [" + str(real_x) +":0] abs_real_x[15:0];\n")
    f.write("    logic [" + str(real_y) +":0] abs_real_y[15:0];\n")
    f.write("    logic [" + str(difference_data) + ":0] data [" + str(num_data) +":0];\n\n")
    for i in range (center_x_00,h):
        for j in range(center_y_00,w):
            f.write("    assign data[" + str(counter) + "] = " + str(difference_data+1) + "'b" + bindigits(data[j][i]-delta_min, 6) + ";\n")
            counter +=1
    f.write("\n")
    f.write("    Coordinate_generator c0(\n")
    f.write("         .p_x(p_x),\n")
    f.write("         .p_y(p_y),\n")
    f.write("         .real_x(real_x),\n")
    f.write("         .real_y(real_y)\n")
    f.write("    );\n")
    f.write("\n")
    f.write("    genvar idx;\n")
    f.write("    generate\n")
    f.write("        for(idx=0; idx<16; idx=idx+1) begin: genXY\n")
    f.write("            abs_X x0(\n")
    f.write("                .x(real_x[idx]),\n")
    f.write("                .abs_real_x(abs_real_x[idx])\n")
    f.write("            );\n")
    f.write("            abs_Y y0(\n")
    f.write("                .y(real_y[idx]),\n")
    f.write("                .abs_real_y(abs_real_y[idx])\n")
    f.write("            );\n")
    f.write("            assign delta[idx] = `DELTA_START + data[abs_real_x[idx]*"+ str(iterate_y) +"+abs_real_y[idx]];\n")
    f.write("        end\n")
    f.write("    endgenerate\n")
    f.write("endmodule\n")
