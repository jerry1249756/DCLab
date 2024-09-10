# NTUEE-DCLAB Group 7
## Introduction
These are lab materials for NTUEE DCLab forked from 
```
https://github.com/sandy30538/NTUEE-DCLAB-Materials.git
```

## Content
* Lab1: RNG
* Lab2: RSA decoder
* Lab3: Audio Reacorder& Player

## Final Project: Real-Time FPGA-based Acoustic Imaging
### Block diagram
![](https://i.imgur.com/ChjdSh4.png)

### Hardware
* Cyclone IV-E DE2-115 FPGA
* INMP441 MEMS microphone*16
* VGA display
* Laser cutting Board, 10cm wide for microphone (with .dxf file in this repo)

### Abstract
We implemented Delay-and-sum Beamforming by 16 MEMS microphones (INMP441) which receives sound data via I2S protocol. The delay $\delta_i(p)$ is generated by the module `delta_generator.sv`, which is automated generated by python file. Next, the data will be stored in ring-buffer which provides access to the delayed delta. Next, for each processed data, we can sum these data and squared in `Add_Square.sv`. The data is truncated and stored into SRAM. Finally, VGA will access the data in SRAM and display the intensity on the screen. Our implementation demonstrates a significant reduction in implementation costs compared to currently high manufacturing costs in the industry.

### DEMO!!
![](https://i.imgur.com/sHGJzrl.png)

The following are recorded demo videos.
`1 sound source`[https://youtu.be/gSOAMRXZsIY]
`2 sound sources`[https://youtu.be/PNLFveaGfNs]


