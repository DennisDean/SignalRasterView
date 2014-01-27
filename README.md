#SignalRasterView

An EDF utility for viewing the headers and signals.  Utility includes an EDF checker and options for troubleshooting an EDF.


##Overview:
SignalRasterView allows the user to review the contents of an EDF file. Once an EDF file is loaded, the user can:
. Echo the header contents to the console 
. Echo the signal header contents to the console or 
. Produce the signal raster plot which is stored in a PowerPoint file,
. Check an EDF content according to the EDF specification, and 
. Deidentify an EDF content.

##Description:
The ability to view the EDF headers allows the users to verify the contents prior to analysis. Viewing the EDF can be helpful to diagnose problems that might arise from file corruptions, differences in the EDF implementation, and/or bugs in EDF export functions.
 
The application supports a limited set of functionality in support of quick review of EDF content. Users can select the EDF file they wish to view. Header and signal header information is also available to the user once the EDF file is loaded in  the interface. The user can select the signal, x-axis scale, lines per page, display gain, and display monitor for  the PowerPoint generated. Users also have the option to customize the PowerPoint file’s title and saved  location.
 
SignalRasterView is a MATALB application created with the MATLAB GUI Development Environment (GUIDE).The most recent version of SignalRaster can be downloaded here. If you are interested in modifying, extending or referencing previous versions, please access the SignalRasterView development site.
 
The most recent version of SignalRasterView can be found here.
 
##Compiled Application (64 Bit Windows):
A compiled form of SignalRasterView can be found here.  The windows executable was created with MATLAB 2013a with the MATLAB Compiler installer (ver 4.18).  Running the application requires MATLAB 2013b or the MATLAB Compiler Runtime for 64 Bit computers.
 
##Included Files:
blockEdfLoad.m, BlockEdfLoadClass.m, BlockEdfDeidentify, blockEdfWrite, ConvertMonitorPosToFigPos.m, pb_select_edf_file.m, saveppt2.m, SignalRasterView.m, signalViewEdfSignals.m, and testSignalViewEdfSignals.m.
 
##Acknowledgements:
SignalRasterView uses saveppt2.m to create a PowerPoint summary. Microsoft PowerPoint is required for PowerPoint generation.

*Version: 0.1.01
