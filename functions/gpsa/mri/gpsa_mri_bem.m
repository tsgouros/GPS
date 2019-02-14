function varargout = gpsa_mri_bem(varargin)
% Constructs the Boundary Element Model
%
% Author: A. Conrad Nied (conrad.logos@gmail.com)
%
% Changelog:
% 2011.11.28 - GPS1.6/mri_bem.m created
% 2012.09.20 - Updated to GPS1.7
% 2012.10.02 - Changed operational structure to work with gpsa_do.m
% 2012.10.03 - Tweaks to report variables, input handling and try/catch
% 2012.11.06 - Fixed error in gpsa_log input
% 2013.04.11 - GPS 1.8, Updated the status check to the new system
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
    
    state.function = 'gpsa_mri_bem';
    tbegin = tic;
    
    subject = gpsa_parameter(state.subject);
    
    %% Make Boundary Model
    
    % If we are overwriting the data set it up so the unix command will
    if(isfield(state, 'override') && state.override)
        overstring = ' --overwrite';
    else
        overstring = '';
    end
    
    % Run the unix command (with explicit mneroot ref -tsg)
    unix_command = sprintf('%s $MNE_ROOT/bin/mne_watershed_bem%s --subject %s',...
                           state.setenv, overstring, subject.name);
    unix(unix_command);
    
    gpsa_log(state, toc(tbegin), unix_command);
    tbegin = tic;
    
    % Run a series of unix commands to copy and rename some of the files
    unix_command = sprintf('cp %s/bem/watershed/%s_brain_surface %s/bem/brain.surf',...
        subject.mri.dir, subject.name, subject.mri.dir);
    unix(unix_command);
    
    unix_command = sprintf('cp %s/bem/watershed/%s_inner_skull_surface %s/bem/inner_skull.surf',...
        subject.mri.dir, subject.name, subject.mri.dir);
    unix(unix_command);
    
    unix_command = sprintf('cp %s/bem/watershed/%s_outer_skull_surface %s/bem/outer_skull.surf',...
        subject.mri.dir, subject.name, subject.mri.dir);
    unix(unix_command);
    
    unix_command = sprintf('cp %s/bem/watershed/%s_outer_skin_surface %s/bem/outer_skin.surf',...
        subject.mri.dir, subject.name, subject.mri.dir);
    unix(unix_command);
    
    % Save the subject structure
    gpsa_parameter(subject)
    
    % Record the process
    gpsa_log(state, toc(tbegin), 'File renaming');
    
end % If we should do the function

%% Add to the report concerning the progress

if(~isempty(strfind(operation, 'p')))
    % Prerequisite: gpsa_mri_setupcoreg
    subject = gpsa_parameter(state, state.subject);
    report.ready    = ~~exist(gps_filename(subject, 'mri_coreg_default'), 'file');
    report.progress = ~isempty(dir(gps_filename(subject, 'mri_bem_surf_gen')));
    report.finished = report.progress == 1;
end

%% Prepare the report and output

if(nargout == 1 && exist('report', 'var')); 
    varargout{1} = report;
end

end % function
