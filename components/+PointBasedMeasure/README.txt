This component has been tested against TOMMAS r642 using MATLAB 2009b

The point based measure is a function that evaluates a trajectory by recovering the corresponding camera motion and scene structure and then comparing the resolved motion to the expected trajectory.
The core is a structure from motion algorithm the employs the following steps:

- SURF point matching
- Essential Matrix estimation using 8-point algorithm
- Decomposition of the essential matrix into motion parameters
- Triangulation of points to recover the structure

MATLAB Version Issue:

If you experience matlab crashing with an error OMP or OPEN MP, this may be caused by a confilct with older versions of MATLAB. If that occurs, try uninstalling all older versions of matlab on your system. 