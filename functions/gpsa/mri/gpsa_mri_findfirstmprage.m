function varargout = gpsa_mri_findfirstmprage(varargin)
% Finds the first T1-MPRAGE file in the subject's raw MRI files
%
% Author: A. Conrad Nied (conrad.logos@gmail.com)
%
% Changelog:
% 2011.11.28 - GPS1.6/mri_findfirstmprage.m created
% 2012.09.19 - Updated to GPS1.7
% 2012.09.21 - Added report.order
% 2012.10.03 - Updated layout for new format and improved -log option
% 2012.11.10 - Fixed problem in unix command
% 2013.04.05 - GPS1.8, The ready condition is now a binary
% 2013.04.11 - Updated the status check to the new system
% 2013.04.24 - Changed subset/subsubset to condition/subset
% 2013.07.02 - Reverted status check to function specific

%% Input

[state, operation] = gpsa_inputs(varargin);

%% Prepare a report on the type or progress of the data

if(~isempty(strfind(operation, 't')))
    report.spec_subj = 1; % Subject specific?
    report.spec_cond = 0; % Condition specific?
end

%% Execute the process

% If it is proper to do the function
if(~isempty(strfind(operation, 'c')))
    
    subject = gpsa_parameter(state.subject);
    state.function = 'gpsa_mri_findfirstmprage';
    tbegin = tic;
    
    %% Find the first T1 MPRAGE file
    
    % Unpack the scanner files
    unix_command = sprintf('unpacksdcmdir -src %s -targ %s -scanonly %s/unpack.log',...
        subject.mri.rawdir, subject.mri.rawdir, subject.mri.rawdir);
    unix(unix_command);
    
    % Scan through the unpack log for the name of the first T1 MPRAGE
    % file
    fid = fopen([subject.mri.rawdir '/unpack.log']);
    while(~feof(fid))
        file_line = fgets(fid);
        if(strfind(file_line, 'T1_MPRAGE_sag'))
            firstfile = textscan(file_line, '%*d %*s %*s %*d %*d %*d %*d %s');
            mpragefile = char(firstfile{1});
            break;
        end
    end % While scanning through file
    
    subject.mri.first_mpragefile = sprintf('%s/%s', subject.mri.rawdir, mpragefile);
    
    gpsa_parameter(subject);
    
    % Record the process
    gpsa_log(state, toc(tbegin), unix_command);
    
end % If we should do the function

%% Add to the report concerning the progress

if(~isempty(strfind(operation, 'p')))
    subject = gpsa_parameter(state, state.subject);
    report.ready = length(dir(subject.mri.rawdir)) > 2;
    report.progress = ~~exist(subject.mri.first_mpragefile, 'file');
    report.finished = report.progress == 1;
end

%% Prepare the report and output

if(nargout == 1 && exist('report', 'var')); 
    varargout{1} = report;
end

end % function