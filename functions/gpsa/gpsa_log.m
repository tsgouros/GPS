function gpsa_log(varargin)
% Makes an annotation in a log file for the study
%
% Author: A. Conrad Nied (anied@cs.washington.edu)
%
% Input: State, program duration, entry
%
% Changelog:
% 2012-01-18 Created as GPS1.6/history.m
% 2012-09-19 Updated to GPS1.7
% 2013-06-28 Updated to GPS1.8, replaced subset with condition
% 2013-11-26 GPS1.9, gets log folder from presets now

%% Get Input

entry = '';
duration = 0;

for i = 1:length(varargin)
    if(ischar(varargin{i}))
        entry = varargin{i};
    elseif(isnumeric(varargin{i}))
        duration = varargin{i};
    elseif(isstruct(varargin{i}))
        state = varargin{i};
    end
end

if(~exist('state', 'var'))
    state = gpsa_get;
end

%% Process log entry

if(~isfield(state, 'function'))
    state.function = 'unk_func';
end
if(~isfield(state, 'condition'))
    state.condition = 'unk_cond';
end
if(~isfield(state, 'subject'))
    state.subject = 'unk_subj';
end

% Get Date
date = datestr(now, 'yyyymmdd HHMMSS');

% Make the duration string
duration_string = '       ';
if(duration > 0); duration_string = sprintf('%3.3f', duration); end

% Write entry
filename = sprintf('%s/%s.log',...
		   gps_presets('logs'), state.study);
try
  fid = fopen(filename, 'a');
  fprintf(fid, '%s\t%s\t%s\t%s\t%s\t%s\n', date, state.function, state.subject, state.condition, duration_string, entry);
  fclose(fid);
catch
  disp(['Error trying to open: ', filename]);
end

end % function
