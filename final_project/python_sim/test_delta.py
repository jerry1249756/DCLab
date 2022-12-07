import numpy as np
import matplotlib.pyplot as plt
from matplotlib.widgets import Slider

pixel_w = 50/300 #pixel pattern will relate to real world's 50(cm)
w = 300
h = 300

v = 34000    # sound speed (cm/s)
fs = 50000   # sampling rate (1/s)

n_microphone = 16
d = 10 # microphone distance (cm)

#pixel is at 100 cm far 
pixel_array = [[np.array([pixel_w*(i-(w-1)/2),pixel_w*(j-(h-1)/2),100]) for i in range (0,w)] for j in range (0,h)]
microphone_array = [[np.array([d*(i-1.5),d*(j-1.5),0]) for i in range (0,4)] for j in range (0,4)]

# Create the figure and the line that we will manipulate
fig, ax = plt.subplots()

data = [[round(fs*np.linalg.norm(pixel_array[i][j] - microphone_array[0][0])/v) for i in range (0,h)]for j in range(0,w)]

#trendline of the margin of points with same delta value: center of (0,0): (60,59.5~60)
x= np.linspace(0,299,300)
center_x_00 = 60
center_y_00 = 59.5

# maps the radius corresponding to the delta value from 147.
radius_map= [46,84,109,130,148,164,179,193,206,218,230,241,252,262,272,282,291,300,309,318,327]
print(len(radius_map))
for i in radius_map:
    temp = center_y_00+ np.sqrt(i**2-(x-center_x_00)**2)
    plt.plot(x, temp)

# shifting of pixels of contingent microphone: 60
# y12 = 179.5+ np.sqrt(46**2-(x-119.5)**2)
# y21 = 119.5+ np.sqrt(46**2-(x-179.5)**2)
# plt.plot(x, y12)
# plt.plot(x, y21)

# draw the map and the color bar on the side
temp = ax.imshow(data, interpolation ='none', aspect = 'auto',  cmap="gray")
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
    ax.imshow(temp, interpolation ='none', aspect = 'auto', cmap="gray")
    fig.canvas.draw_idle()

x_slider.on_changed(update)
y_slider.on_changed(update)

plt.show()