function varargout = gpsa_mri_import(varargin)
% Imports the subject's data for a MRI study
%
% Author: A. Conrad Nied (conrad.logos@gmail.com)
%
% Changelog:
% 2011.11.29 - GPS1.6/mri_import.m created
% 2012.09.19 - Updated to GPS1.7, first routine to be updated
% 2012.09.21 - Added order
% 2012.10.03 - Updated layout for new format
% 2013.04.11 - GPS 1.8, Updated the status check to the new system
% 2013.04.24 - Changed subset/subsubset to condition/subset
% 2013.07.02 - Reverted status check to function specific
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
    
    subject = gpsa_parameter(state.subject);
    state.function = 'gpsa_mri_import';
    tbegin = tic;
    
    % Make containing folder
    if(~exist(subject.mri.dir, 'dir'))
        mkdir(subject.mri.rawdir);
    end
    
    %% 1) Find where the data is
    
    % Ask the user where the data is from
    choice = questdlg('Where is the raw MRI data located?',... % Question
        'raw MRI location',... % Title
        'Bourget', 'CD / Select Dir',... % Choices
        'Bourget'); % Default
    
    switch choice
        case 'Bourget'
            % Use the findsession terminal command to find the file
            %% Added explicit reference to fshome.  -tsg
            fscommand = sprintf('%s/bin/findsession %s',...
                                state.fshome, subject.name)
            [~, returned_text] = unix(fscommand);
            
            % Cut out the part of the returned text that says were the file is
            % located
            slashes = strfind(returned_text, '/');
            subject.mri.sourcedir = returned_text(slashes(1):(end - 1));
            
        case 'CD / Select Dir'
            subject.mri.sourcedir = uigetdir();
    end % Which choice are they
    
    % Save the directory change to the subject parameter file
    gpsa_parameter(subject);
    
    %% 2) Copy and Paste Data into MRI Folder
    
    % Simple command, this is sufficient but does not give user feedback
    % unix_command = sprintf('cp %s/* %s/', subject.mri.sourcedir, subject.mri.dir);
    % unix(unix_command);
    
    % Complex Command that gives user feedback
    fprintf('Copying Files from %s to %s\n', subject.mri.sourcedir, subject.mri.rawdir);
    files = dir(subject.mri.sourcedir);
    N_files = length(files);
    
    for i_file = 1:N_files % For Each file
        filename = files(i_file).name;
        
        if(~strcmp(filename, '.') && ~strcmp(filename, '..')); % If the file is not a linux folder item
            
            % Show progress in command window
            fprintf('Copying file %4d/%4d: %s\n', i_file, N_files, filename);
            
            % Copy file over
            copyfile([subject.mri.sourcedir '/' filename], subject.mri.rawdir);
            
        end % if linux folder direct
    end % For each file
    
    % Record the process
    gpsa_log(state, toc(tbegin));
    
end % If we should do the function

%% Add to the report concerning the progress

if(~isempty(strfind(operation, 'p')))
    subject = gpsa_parameter(state, state.subject);
    report.ready = 1;
    report.progress = length(dir(subject.mri.rawdir)) > 2;
    report.finished = report.progress == 1;
end

%% Prepare the report and output

if(nargout == 1 && exist('report', 'var')); 
    varargout{1} = report;
end

end % function
