function gps_PTC3toAR1
% Transfers study information between studies PTC3 and AR1
%
% Author: A. Conrad Nied
%
% Changelog:
% 2013.01.11 - Created in GPS1.7

state_a = gpsa_get;

state_p = state_a;
state_p.study = 'PTC3';

AR1 = gpsa_parameter(state_a, 'AR1');
PTC3 = gpsa_parameter(state_p, 'PTC3');

for i_subject = 1:length(AR1.subjects)
    
    % Make subject
    AR1_s.name = PTC3.subjects{i_subject};
    PTC3_s = gpsa_parameter(state_p, AR1_s.name);
    AR1_s.name = sprintf('AR1_%s', AR1_s.name(end-1:end));
    AR1_s = gpse_convert_subject(AR1_s.name, state_a);
    
    fprintf('%s -> AR1\n', PTC3_s.name);
    
    %% MEG Directory
    mkdir(AR1_s.meg.dir)
    
    % Symbolic link to the original directory
    unix_command = sprintf('ln -s %s %s/%s', PTC3_s.meg.dir, AR1_s.meg.dir, PTC3_s.name);
    unix(unix_command);
    
    % Bad Channel
    source = sprintf('%s/%s_bad_channels.txt', PTC3_s.meg.dir, PTC3_s.name);
    destination = sprintf('%s/%s_bad_channels.txt', AR1_s.meg.dir, AR1_s.name);
    fprintf('\t%s -> AR1\n', source);
    copyfile(source, destination); 
    
    mkdir([AR1_s.meg.dir '/analysis_commands'])
    mkdir([AR1_s.meg.dir '/averages'])
    
    % Inverse Solution
    source = sprintf('%s', PTC3_s.mne.invfile);
    PTC3_loc = strfind(source, PTC3_s.name);
    destination = sprintf('%s/averages/%s%s', AR1_s.meg.dir, PTC3_s.name, source(PTC3_loc(end) + 7:end));
    fprintf('\t%s -> AR1\n', source);
    copyfile(source, destination); 
    
    % Forward Solution
    source = sprintf('%s', PTC3_s.mne.fwdfile);
    PTC3_loc = strfind(source, PTC3_s.name);
    destination = sprintf('%s/averages/%s%s', AR1_s.meg.dir, PTC3_s.name, source(PTC3_loc(end) + 7:end));
    fprintf('\t%s -> AR1\n', source);
    copyfile(source, destination); 
    
    mkdir([AR1_s.meg.dir '/behaviorals'])
    mkdir([AR1_s.meg.dir '/logs'])
    mkdir([AR1_s.meg.dir '/processed_data'])
    mkdir([AR1_s.meg.dir '/raw_data'])
    
    % A1
    source = sprintf('%s/raw_data/%s_A1_raw.fif', PTC3_s.meg.dir, PTC3_s.name);
    destination = sprintf('%s/raw_data/%s_A1_raw.fif', AR1_s.meg.dir, AR1_s.name);
    if(exist(source, 'file'))
        fprintf('\t%s -> AR1\n', source);
        copyfile(source, destination);
    end
    
    % A2
    source = sprintf('%s/raw_data/%s_A2_raw.fif', PTC3_s.meg.dir, PTC3_s.name);
    destination = sprintf('%s/raw_data/%s_A2_raw.fif', AR1_s.meg.dir, AR1_s.name);
    if(exist(source, 'file'))
        fprintf('\t%s -> AR1\n', source);
        copyfile(source, destination);
    end
    
    % Emptyroom
    source = sprintf('%s/raw_data/%s_emptyroom_raw.fif', PTC3_s.meg.dir, PTC3_s.name);
    destination = sprintf('%s/raw_data/%s_emptyroom_raw.fif', AR1_s.meg.dir, AR1_s.name);
    if(exist(source, 'file'))
        fprintf('\t%s -> AR1\n', source);
        copyfile(source, destination);
    end
    
    % EOG Projections
    source = sprintf('%s/raw_data/%s_eog_proj.fif', PTC3_s.meg.dir, PTC3_s.name);
    destination = sprintf('%s/raw_data/%s_eog_proj.fif', AR1_s.meg.dir, AR1_s.name);
    if(exist(source, 'file'))
        fprintf('\t%s -> AR1\n', source);
        copyfile(source, destination);
    end
    
    % EOG Test (subject probably doesn't have this
    source = sprintf('%s/raw_data/%s_eog_test.fif', PTC3_s.meg.dir, PTC3_s.name);
    destination = sprintf('%s/raw_data/%s_eog_test.fif', AR1_s.meg.dir, AR1_s.name);
    if(exist(source, 'file'))
        fprintf('\t%s -> AR1\n', source);
        copyfile(source, destination);
    end
    
    mkdir([AR1_s.meg.dir '/stcs'])
    mkdir([AR1_s.meg.dir '/triggers'])
    
    %% MRI
    
    % Symbolic link to the raw directory
    unix_command = sprintf('ln -s %s %s', PTC3_s.mri.rawdir, AR1_s.mri.rawdir);
    unix(unix_command);
    
    % MRI / Surface
    source = sprintf('%s/*', PTC3_s.mri.dir);
    destination = sprintf('%s', AR1_s.mri.dir);
    fprintf('\t%s -> AR1\n', source);
    copyfile(source, destination);
    
    % Symbolic link to the oll directory
    unix_command = sprintf('ln -s %s %s/%s', PTC3_s.mri.dir, AR1_s.mri.dir, PTC3_s.name);
    unix(unix_command);
    
    % Rename all files to match AR1
    path = genpath(AR1_s.mri.dir);
    i_paths = [0 find(path == pathsep) length(path)+1];
    
    % Search through the paths
    for i_folder = 1:length(i_paths) - 1
        folder = path(i_paths(i_folder) + 1 : i_paths(i_folder + 1) - 1);
        
        % Renames the files in the folders
        files = dir([folder '/' PTC3_s.name '*']);
        
        if(~isempty(files))
            
            % Rename each file
            for i_file = 1:length(files)
                source = sprintf('%s/%s', folder, files(i_file).name);
                destination = sprintf('%s/%s%s', folder, AR1_s.name, files(i_file).name(8:end));
%                 fprintf('\t%s\n\t\t%s\n', source, destination);
                movefile(source, destination);
            end % for each file, rename
        end % If we have files with the old name
    end % for each folder in the MRI directory
    
end

% Analysis
% Redo Behaviorals Events and Apply
% Make sure the bad channels and eog are up to date
% Calculate MNE and on

end