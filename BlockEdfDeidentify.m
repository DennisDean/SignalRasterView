function status = BlockEdfDeidentify (varargin)
% Deidentify file in place, with out rewriting.  Backup of file is
% reccomended prior to use.
%
%
% Function Prototypes:
%       status = BlockEdfDeidentify\n');
%       status = BlockEdfDeidentify(edfFn, patient_id, recording_startdate)
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
% File created: October 23, 2012
% Last updated: November 21, 2013 
%    
% Copyright © [2012] The Brigham and Women's Hospital, Inc. THE BRIGHAM AND 
% WOMEN'S HOSPITAL, INC. AND ITS AGENTS RETAIN ALL RIGHTS TO THIS SOFTWARE 
% AND ARE MAKING THE SOFTWARE AVAILABLE ONLY FOR SCIENTIFIC RESEARCH 
% PURPOSES. THE SOFTWARE SHALL NOT BE USED FOR ANY OTHER PURPOSES, AND IS
% BEING MADE AVAILABLE WITHOUT WARRANTY OF ANY KIND, EXPRESSED OR IMPLIED, 
% INCLUDING BUT NOT LIMITED TO IMPLIED WARRANTIES OF MERCHANTABILITY AND 
% FITNESS FOR A PARTICULAR PURPOSE. THE BRIGHAM AND WOMEN'S HOSPITAL, INC. 
% AND ITS AGENTS SHALL NOT BE LIABLE FOR ANY CLAIMS, LIABILITIES, OR LOSSES 
% RELATING TO OR ARISING FROM ANY USE OF THIS SOFTWARE.
%

% Initialize return
status = 0;

% Process Input parameters
if nargin == 1
    edfFn = varargin {1};
elseif nargin == 3
    edfFn = varargin {1};    
    recording_startdate = varargin {2};
    patient_id = varargin {3};
else
    fprintf('status = BlockEdfDeidentify\n');
    fprintf('status = BlockEdfDeidentify(edfFn, patient_id, recording_startdate)\n');
end

% Get header from file
header = blockEdfLoad(edfFn);

% Remove deidentifying information
header.recording_startdate = '06.12.04';
header.patient_id = ' ';

% Write Changes to file
if ~isempty(header)
    status = blockEdfWrite(edfFn, header);
end

end