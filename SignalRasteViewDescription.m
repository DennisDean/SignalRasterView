function SignalRasteViewDescription
%signalRasteViewDescription Signal raster view description
%   Compiled released prior to source code release
%
% Overview:
% SignalRasterView allows the user to review the contents of an EDF file. 
% Once an EDF file is loaded, the user can (1) echo the header contents to 
% the console, (2) echo the signal header contents to the console or 
% (3) produce the signal raster plot which is stored in a PowerPoint file,
% (4) Check an EDF content according to the EDF specification, and 
% (5) Deidentify an EDF content.
%
% Description:
% The ability to view the EDF headers allows the users to verify the 
% contents prior to analysis. Viewing the EDF can be helpful to diagnose 
% problems that might arise from file corruptions, differences in the EDF 
% implementation, and/or bugs in EDF export functions.
% 
% The application supports a limited set of functionality in support of 
% quick review of EDF content. Users can select the EDF file they wish to 
% view. Header and signal header information is also available to the user 
% once the EDF file is loaded in  the interface. The user can select the 
% signal, x-axis scale, lines per page, display gain, and display monitor 
% for  the PowerPoint generated. Users also have the option to customize 
% the PowerPoint file’s title and saved  location.
% 
% SignalRasterView is a MATALB application created with the MATLAB GUI 
% Development Environment (GUIDE).The most recent version of SignalRaster 
% can be downloaded here. If you are interested in modifying,  extending 
% or referencing previous versions, please access the SignalRasterView 
% development site.
% 
% The most recent version of SignalRasterView can be found here.
% 
% Compiled Application (64 Bit Windows):
% A compiled form of SignalRasterView can be found here.  The windows 
% executable was created with MATLAB 2013a with the MATLAB Compiler 
% installer (ver 4.18).  Running the application requires MATLAB 2013b or 
% the MATLAB Compiler Runtime for 64 Bit computers.
% 
% Included Files:
% blockEdfLoad.m, BlockEdfLoadClass.m, BlockEdfDeidentify, blockEdfWrite
% ConvertMonitorPosToFigPos.m, pb_select_edf_file.m, saveppt2.m, 
% SignalRasterView.m, signalViewEdfSignals.m, and 
% testSignalViewEdfSignals.m.
% 
% Acknowledgements:
% SignalRasterView uses saveppt2.m to create a PowerPoint summary. 
% Microsoft PowerPoint is required for PowerPoint generation.
%
% Version: 0.1.01
%
% ---------------------------------------------
% Dennis A. Dean, II, Ph.D
%
% Program for Sleep and Cardiovascular Medicine
% Brigam and Women's Hospital
% Harvard Medical School
% 221 Longwood Ave
% Boston, MA  02149
%
% File created: January 27, 2014
% Last update:  January 27, 2014 
%    
% Copyright © [2014] The Brigham and Women's Hospital, Inc. THE BRIGHAM AND 
% WOMEN'S HOSPITAL, INC. AND ITS AGENTS RETAIN ALL RIGHTS TO THIS SOFTWARE 
% AND ARE MAKING THE SOFTWARE AVAILABLE ONLY FOR SCIENTIFIC RESEARCH 
% PURPOSES. THE SOFTWARE SHALL NOT BE USED FOR ANY OTHER PURPOSES, AND IS
% BEING MADE AVAILABLE WITHOUT WARRANTY OF ANY KIND, EXPRESSED OR IMPLIED, 
% INCLUDING BUT NOT LIMITED TO IMPLIED WARRANTIES OF MERCHANTABILITY AND 
% FITNESS FOR A PARTICULAR PURPOSE. THE BRIGHAM AND WOMEN'S HOSPITAL, INC. 
% AND ITS AGENTS SHALL NOT BE LIABLE FOR ANY CLAIMS, LIABILITIES, OR LOSSES 
% RELATING TO OR ARISING FROM ANY USE OF THIS SOFTWARE.
%

end

