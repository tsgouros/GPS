function varargout = gpsa_mne_stcave(varargin)
% Make an average brain STC movie file based on the primary conditions and
% inverse solution
%
% Author: A. Conrad Nied (conrad.logos@gmail.com)
%
% Changelog:
% 2012.01.23 - Originally created from GPS1.7(-)/gpsa_mne_stc.m
% 2012.10.08 - Updated to GPS1.7 format
% 2012.10.10 - Correct for N == 0 in progress report
% 2012.10.14 - Subset specific now
% 2013.04.16 - GPS 1.8, Updated the status check to the new system and
% added gps_filename identifiers for files
% 2013.04.24 - Changed subset/subsubset to condition hierarchy
% 2013.04.26 - Directly finds the condition's # from the avefile
% 2013.05.01 - Modified status check
% 2013.06.20 - Reverted the status check to the individual system
% 2013.07.10 - Uses condition brain instead of study.average_brain

%% Input

[state, operation] = gpsa_inputs(varargin);

%% Prepare a report on the type or progress of the data

if(~isempty(strfind(operation, 't')))
    report.spec_subj = 1; % Subject specific?
    report.spec_cond = 2; % Condition specific?
end

%% Execute the process

if(~isempty(strfind(operation, 'c')))
    
    subject = gpsa_parameter(state, state.subject);
    condition = gpsa_parameter(state, state.condition);
    state.function = 'gpsa_mne_stcave';
    tbegin = tic;
    
    smooth_level = 5;
    
    % Make the STC folder
    folder = sprintf('%s/stcs', subject.meg.dir);
    if(~exist(folder, 'dir')); mkdir(folder); end
    
    stcfilename_orig = gps_filename(subject, condition, 'mne_stc');
    stcfilename = gps_filename(subject, condition, 'mne_stc_avebrain');
    
    % Specify time
    if (condition.event.basestart < condition.event.basestop) % If there is a baseline measure
        timespec = sprintf('--tmin %d --tmax %d --tstep 1 --bmin %d --bmax %d',...
            condition.event.start + 1, condition.event.stop, condition.event.basestart, condition.event.basestop);
    else
        timespec = sprintf('--tmin %d --tmax %d --tstep 1',...
            condition.event.start + 1, condition.event.stop);
    end
    
    % Process unix command (added explicit mnehome reference. -tsg)
    unix_command = sprintf('%s/bin/mne_make_movie --inv %s --stcin %s --smooth %d --morph %s  --surface inflated --stc %s --subject %s %s',...
        state.mnehome, subject.mne.invfile, stcfilename_orig, smooth_level, condition.cortex.brain, stcfilename, subject.name, timespec);
    unix(unix_command);
    gpsa_log(state, toc(tbegin), unix_command);
    
end % If we should do the function

%% Add to the report concerning the progress

if(~isempty(strfind(operation, 'p')))
    study = gpsa_parameter(state, state.study);
    subject = gpsa_parameter(state, state.subject);
    condition = gpsa_parameter(state, state.condition);
    if(strcmp(condition.cortex.brain, condition.subjects{1}))
        report.ready = 0; report.progress = 0; report.applicable = 0;
    else
        report.ready = (double(~~exist(gps_filename(subject, condition, 'mne_stc_lh'), 'file')) + ...
            (length(dir([study.mri.dir '/' condition.cortex.brain])) > 2)) / 2;
        report.progress = ~~exist(gps_filename(subject, condition, 'mne_stc_avebrain_lh'), 'file');
    end
    report.finished = report.progress == 1;
end

%% Prepare the report and output

if(nargout == 1 && exist('report', 'var')); 
    varargout{1} = report;
end

end % function
