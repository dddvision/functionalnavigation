% This class depends on libusb-devel (version >= 1.0.8.20101017) and libfreenect (version >= 0.1.1)
% 
% 1) Setup the environment. The following steps are for a Mac, but similar steps work on Linux and Windows.
% 
% 1.A) Install a C/C++ compiler. (Xcode is available from the App Store)
% 
% 1.B) Download and install CMake from here:
% http://www.cmake.org/
% 
% 1.C) Download and install MacPorts from here:
% http://www.macports.org/
% 
% 1.D) Install libusb-devel by using the port command in a terminal window.
% sudo port install libusb-devel
% 
% 1.E) Download and unzip libfreenect from here:
% https://github.com/OpenKinect/libfreenect
% You can name the directory anything you want. We will refer to it as MyProject.
% 
% 2) Configure and compile the example code.
% 
% 2.A) Create the build configuration for your machine:
% > cd MyProject
% > cmake CMakeLists.txt
% 
% 2.B) Compile the example code. Refer to web forums to resolve any errors that may occur.
% > make
% 
% 3) Install and compile the code that comes with this project:
% 
% 3.A) Open MyProject/wrappers/cpp/cppview.cpp in a text editor.
% 
% 3.B) Open [functionalnavigation]/components/+XBOXKinect/kinectapp.cpp
% 
% 3.C) Copy the kinectapp.cpp code and overwrite the contents of cppview.cpp.
% 
% 3.D) Compile the new code. If there are errors, then submit an issue to the Issue Tracker.
% > cd MyProject
% > make
% 
% 4) Prepare the Kinect hardware.
% 
% 4.A) Remove all USB devices.
% 
% 4.B) Plugin the power cord to the Kinect sensor, then plugin the USB cable to your computer.
%
% 5) Copy the executable to this directory and call it kinectapp
% > cp MyProject/bin/cppview [functionalnavigation]/components/+XBOXKinect/kinectapp

classdef XBOXKinectConfig < handle
  properties (Constant = true)   
    % Kinect depth image horizontal field of view in radians (57.8/180*pi, image is closer to 62.7/180*pi)
    depthFieldOfView = 57.8/180*pi;
    
    % Maximum time in seconds to wait for individual sensor initialization (10)
    timeOut = 10;
    
    % Attempt to recompile the Kinect application used by this component (false)
    recompile = false;
    
    % Overwrite stored images (false)
    overwrite = true;
    
    % display warnings and other diagnostic information (true)
    verbose = true; 
  end
end
