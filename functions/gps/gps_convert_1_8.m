function gps_convert_1_8
% Converts the folder/file scheme from GPS1.7 to GPS1.8
%
% Author: A. Conrad Nied
%
% Changelog:
% 2013.04.26 - Created

state = gpsa_get;
study = gpsa_parameter(state, state.study);

% For all subjects
for i_subject = 1:length(study.subjects)
    subject = gpsa_parameter(state, study.subjects{i_subject});
    
    % Make the MNE folder
    destination = sprintf('%s/%s', study.mne.dir, subject.name);
    [~, ~, ~] = mkdir(destination);
    subject.mne.dir = destination;
    
    % Move the Averages folder
    source = sprintf('%s/averages/', subject.meg.dir);
    destination = sprintf('%s', subject.mne.dir);
    if(~exist(source, 'dir') && ~exist(destination, 'dir'));
        fprintf('%s mne averages folder doesn''t exist\n', subject.name);
    elseif(~exist(destination, 'dir'));
        movefile(source, destination);
        rmdir(source)
    end
    
    % Rename the MNE filenames
    source = subject.mne.avefile;
    destination = sprintf('%s/%s', subject.mne.dir,...
        source(find(source == '/', 1, 'last')+1:end));
    if(~exist(destination, 'file')); fprintf('%s mne avefile doesn''t exist\n', subject.name);
    else subject.mne.avefile = destination; end
    
    source = subject.mne.covfile;
    destination = sprintf('%s/%s', subject.mne.dir,...
        source(find(source == '/', 1, 'last')+1:end));
    if(~exist(destination, 'file')); fprintf('%s mne covfile doesn''t exist\n', subject.name);
    else subject.mne.covfile = destination; end
    
    source = subject.mne.fwdfile;
    destination = sprintf('%s/%s', subject.mne.dir,...
        source(find(source == '/', 1, 'last')+1:end));
    if(~exist(destination, 'file')); fprintf('%s mne fwdfile doesn''t exist\n', subject.name);
    else subject.mne.fwdfile = destination; end
    
    source = subject.mne.invfile;
    destination = sprintf('%s/%s', subject.mne.dir,...
        source(find(source == '/', 1, 'last')+1:end));
    if(~exist(destination, 'file')); fprintf('%s mne invfile doesn''t exist\n', subject.name);
    else subject.mne.invfile = destination; end
    
    % Rename the triggers folder
    source = sprintf('%s/triggers', subject.meg.dir);
    destination = sprintf('%s/events', subject.mne.dir);
    if(~exist(source, 'dir') && ~exist(destination, 'dir')); fprintf('%s mne averages folder doesn''t exist\n', subject.name);
    elseif(~exist(destination, 'dir')); movefile(source, destination); end
    
    gpsa_parameter(state, subject)
end % for all subjects

% For all conditions
for i_condition = 1:length(study.conditions)
    condition = gpsa_parameter(state, study.conditions{i_condition});
    
    gpsa_parameter(state, condition)
end % for all conditions

% For all subjects and conditions


end