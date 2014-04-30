function [edf_fn edf_pn edf_file_is_selected ] = ...
                                       pb_select_edf_file(current_edf_path)
%pb_select_EDF_file Select EDF file
%   File created to facilitate building GUI's from command line routines
%
% Version: 0.1.13
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
% File created: October 23, 2012
% Last update:  May 16, 2012 
%    
% Copyright © [2013] The Brigham and Women's Hospital, Inc. THE BRIGHAM AND 
% WOMEN'S HOSPITAL, INC. AND ITS AGENTS RETAIN ALL RIGHTS TO THIS SOFTWARE 
% AND ARE MAKING THE SOFTWARE AVAILABLE ONLY FOR SCIENTIFIC RESEARCH 
% PURPOSES. THE SOFTWARE SHALL NOT BE USED FOR ANY OTHER PURPOSES, AND IS
% BEING MADE AVAILABLE WITHOUT WARRANTY OF ANY KIND, EXPRESSED OR IMPLIED, 
% INCLUDING BUT NOT LIMITED TO IMPLIED WARRANTIES OF MERCHANTABILITY AND 
% FITNESS FOR A PARTICULAR PURPOSE. THE BRIGHAM AND WOMEN'S HOSPITAL, INC. 
% AND ITS AGENTS SHALL NOT BE LIABLE FOR ANY CLAIMS, LIABILITIES, OR LOSSES 
% RELATING TO OR ARISING FROM ANY USE OF THIS SOFTWARE.
%
    
% Program Constant
DEBUG = 1;


% Select file to open. 
[edf_fn, edf_pn, filterindex] = uigetfile( ...
{  '*.edf','EDF Files (*.edf)'; ...
   '*.EDF','EDF Files (*.EDF)'; ...
   '*.*',  'All Files (*.*)'}, ...
   'Select EDF files', ...
   current_edf_path,...
   'MultiSelect', 'off');

% Check output
if isequal(edf_fn,0)
   edf_file_is_selected = 0;
else
   edf_file_is_selected = 1;
end

end

