## Example: Data Acquisition with Deep Memory Mode in the Moku Oscilloscope
#
# This example demonstrates how to acquire data using the deep memory mode in the Moku Oscilloscope.
#
# The 'save_high_res_buffer' command stores high-resolution channel buffer data in Moku's internal storage.
#
# Ensure that deep memory mode is enabled using the 'set_acquisition_mode' command before exporting high-res data.
#
# Logged data files can be retrieved from the following storage locations:
#   - 'persist' for Moku:Go
#   - 'tmp' for Moku:Lab
#   - 'ssd' for Moku:Pro
# Update the 'download' command accordingly to match the correct storage location.
#
# The parameters in the 'set_frontend' command should be configured to align with the specific hardware (Moku:Go, Moku:Lab, or Moku:Pro).


import matplotlib.pyplot as plt
import os
import time
import numpy as np

from moku.instruments import Oscilloscope

# Connect to your Moku by its ip address using Oscilloscope('192.168.###.###')

i = Oscilloscope('XXX.XXX.X.XXX', force_connect=True)

NUM_FRAMES = 1
FILE_PATH = "C:/Users/XXXX/Downloads" # Please replace with your own FILE_PATH

try:

    i.set_trigger(type='Edge', source='Input1', level=0)

    # View +-5 msec, i.e. trigger in the centre
    
    i.set_timebase(-5e-3, 5e-3)
    
    i.set_acquisition_mode('DeepMemory')
    print(i.get_samplerate())

    # Set the data source of Channel 1 to be Input 1
    i.set_frontend(1,'50Ohm','AC','400mVpp')
    i.set_source(1, 'Input1')

    i.set_source(2, 'None')
    i.set_source(3, 'None')
    i.set_source(4, 'None')

    # Get initial data frame to set up plotting parameters.
    data = i.get_data()

    # Set up the plotting parameters
    plt.ion()
    plt.show()
    plt.grid(visible=True)
    plt.ylim([-1, 1])
    plt.xlim([data['time'][0], data['time'][-1]])

    line1, = plt.plot([])

    # Configure labels for axes
    ax = plt.gca()
      
    for iter in range(0, NUM_FRAMES):
        iter = iter + 1
        i.get_data()
        response = i.save_high_res_buffer(comments="Triggered")
        file_name = response["file_name"]
        temp_filename = FILE_PATH + "/high_res_data-" + time.strftime('%d-%m-%Y-%H_%M_%S')
        i.download("ssd", file_name, temp_filename + ".li")
        os.system("mokucli convert --format=npy " + temp_filename + ".li")
        data_load = np.load(temp_filename + ".npy")
        data = np.array(data_load.tolist())
        if iter == 1:
            ch1 = data[:,1]
        else:
            ch1 = ch1 + data[:,1]
                
    time_column = data[:,0]
        
    line1.set_ydata(ch1/NUM_FRAMES) # calculate the average of all acquired high-res frames
    line1.set_xdata(time_column)
        
except Exception as e:
    print(f'Exception occurred: {e}')
finally:
    # Close the connection to the Moku device
    # This ensures network resources and released correctly
    i.relinquish_ownership()
