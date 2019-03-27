function varargout = gpsa_meg_import(varargin)
% Imports the subject's data from a MEG scan
%
% Author: A. Conrad Nied (conrad.logos@gmail.com)
%
% Changelog:
% 2011.11.28 - Originally created as GPS1.6(-)/meg_import.m
% 2012.10.03 - Updated to GPS1.7 format
% 2012.10.05 - Checks channel alignment now too
% 2013.01.14 - Changed preallocated folders
% 2013.01.18 - Added permissions change
% 2013.04.17 - GPS1.8 progress and accepts string meg raids
% 2013.04.24 - Changed subset/subsubset to condition hierarchy
% 2013.05.03 - Gets (folder)filenames from the gps_filename function
% 2013.06.24 - Reverted to old status protocol
% 2019.01.15 - Tried to relieve dependence on MGH/Martinos file system. -tsg
% 2019.01-03 - Added explicit pathname references to environment vars.  -tsg

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

    study = gpsa_parameter(state, state.study);
    subject = gpsa_parameter(state, state.subject);
    state.function = 'gpsa_meg_import';
    tbegin = tic;

    % Functional instructions
    %% 0) Setup Subject Folders
    dir_scans = gps_filename(subject, 'meg_scan_dir');
    [~, ~, ~] = mkdir(dir_scans);
    [~, ~, ~] = mkdir(gps_filename(study, subject, 'meg_scan_filtered_dir'));
    [~, ~, ~] = mkdir(gps_filename(study, subject, 'meg_events_dir'));
    [~, ~, ~] = mkdir(gps_filename(study, subject, 'meg_evoked_dir'));
    [~, ~, ~] = mkdir(gps_filename(study, subject, 'meg_images_dir'));

    %% 1) Declare which megraid harddrive the data is saved to
    %% This stuff is a convenience for people at Martinos, and is being removed
    %% so it doesn't inconvenience others. You guys can remember where things are. -tsg
    %% raid = inputdlg({'Megraid Harddrive'}, 'MEG Process', 1, {subject.meg.raid});
    %% subject.meg.raid = raid{1};

    %% 2) Find the directory with the data
    %% subject.meg.sourcedir = sprintf('/space/megraid/%s/MEG/%s/subj_%s',...
    %%    subject.meg.raid, study.meg.raid_pi, subject.name);
    % If the source directory is as expected, run, otherwise (or if the
    % user specified) get from user input. Also check that it only has one
    % date
    %%if(exist(subject.meg.sourcedir, 'dir') && length(ls(subject.meg.sourcedir)) < 9)
    %%    datedir = ls(subject.meg.sourcedir);
    %%    subject.meg.sourcedir = [subject.meg.sourcedir '/' datedir(1:end-1)];
    %%else
    subject.meg.sourcedir = uigetdir(state.datadir,...
            'Select the directory with the raw meg files');
    %% end

    %% 3) Copy the Data

    % Complex Command that gives user feedback
    fprintf('Copying Files from %s to %s\n', subject.meg.sourcedir, dir_scans);
    files = dir(subject.meg.sourcedir);
    N_files = length(files);

    for i_file = 1:N_files % For Each file
        filename = files(i_file).name;

        if(~strcmp(filename, '.') && ~strcmp(filename, '..')); % If the file is not a linux folder item

            % Show progress in command window
            fprintf('Copying file %2d/%2d: %s\n', i_file, N_files, filename);

            % Copy file over
            copyfile([subject.meg.sourcedir '/' filename], dir_scans);

            % Open permissions if necessary
            unix_command = sprintf('chmod ug+rw %s/%s',...
                dir_scans, filename);
            unix(unix_command);

            % Check channel alignment (with explicit mne root ref -tsg)
            unix_command = sprintf('%s $MNE_ROOT/bin/mne_check_eeg_locations --fix --file %s/%s',...
                                   state.setenv, dir_scans, filename);
            unix(unix_command);

        end % if linux folder direct
    end % For each file


    %% Save Data and Record History

    % Record the process
    gpsa_parameter(subject);
    gpsa_log(state, toc(tbegin));

end % If we should do the function

%% Add to the report concerning the progress

if(~isempty(strfind(operation, 'p')))
    subject = gpsa_parameter(state, state.subject);
    report.ready = 1;
    report.progress = ~isempty(dir(gps_filename(subject, 'meg_scan_gen')));
    report.finished = report.progress == 1;
end

%% Prepare the report and output

if(nargout == 1 && exist('report', 'var'));
    varargout{1} = report;
end

end % function
