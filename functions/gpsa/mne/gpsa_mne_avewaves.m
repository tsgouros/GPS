function varargout = gpsa_mne_avewaves(varargin)
% Averages the raw MEG data (and builds the covariance files too)
%
% Author: A. Conrad Nied (conrad.logos@gmail.com)
%
% Changelog:
% 2011.11.28 - Originally created as GPS1.6(-)mne_avecov/.m
% 2012.05.29 - Last modified in GPS1.6(-)
% 2012.10.08 - Updated to GPS1.7 format
% 2013.04.12 - GPS1.8, Updated the status check to the new system
% 2013.04.24 - Changed subset/subsubset to condition hierarchy
% 2013.04.29 - Changed file organization
% 2013.06.13 - Changed the way time is organized

%% Input

[state, operation] = gpsa_inputs(varargin);

%% Prepare a report on the type or progress of the data

if(~isempty(strfind(operation, 't')))
    report.spec_subj = 1; % Subject specific?
    report.spec_cond = 0; % Condition specific? but does affect level 1
end

%% Execute the process

if(~isempty(strfind(operation, 'c')))
    
    study = gpsa_parameter(state.study);
    subject = gpsa_parameter(state.subject);
    state.function = 'gpsa_mne_avewaves';
    tbegin = tic;
    
    % Make folders that may not already exist
    dir_subjmne = sprintf('%s', subject.mne.dir);
    if(~exist(dir_subjmne, 'dir')); mkdir(dir_subjmne); end
    
    dir_aveblocks = gps_filename(subject, 'mne_block_dir');
    if(~exist(dir_aveblocks, 'dir')); mkdir(dir_aveblocks); end
    
    dir_cmd = gps_filename(subject, 'mne_commands_dir');
    if(~exist(dir_cmd, 'dir')); mkdir(dir_cmd); end
    
    dir_logs = gps_filename(subject, 'mne_logs_dir');
    if(~exist(dir_logs, 'dir')); mkdir(dir_logs); end
    
    dir_scanfilt = gps_filename(subject, 'meg_scan_filtered_dir');
    if(~exist(dir_scanfilt, 'dir')); mkdir(dir_scanfilt); end
    
    %% 1) Write down average and covariance parameters
    
    % For each block
    for i_block = 1:length(subject.blocks)
        block = subject.blocks{i_block};
        
        % Write Average File
        
        ave_file = sprintf('%s/%s_%s.ave',...
            dir_cmd, subject.name, block);
        fid = fopen(ave_file, 'w');
        
        fprintf(fid, 'average {\n');
        fprintf(fid, '\t outfile %s\n',...
            gps_filename(subject, 'mne_ave_block', ['block=' block]));
        fprintf(fid, '\t eventfile %s\n',...
            gps_filename(subject, 'meg_events_grouped_block', ['block=' block]));
        fprintf(fid, '\t logfile %s\n',...
            gps_filename(subject, 'mne_ave_log_block', ['block=' block]));
        fprintf(fid, '\t gradReject %.2d\n', study.mne.gradreject);
        fprintf(fid, '\t magReject %.2d\n', study.mne.magreject);
        if(study.mne.eogreject > 0)
            fprintf(fid, '\t eogReject %d\n', study.mne.eogreject);
        else
            fprintf(fid, '\t #eogReject 150e-6\n');
        end
        fprintf(fid, '\t name %s_%s\n', subject.name, block);
        
        % For each condition
        for i_condition = 1:length(study.conditions);
            condition = study.conditions{i_condition};
            condition = gpsa_parameter(condition);
            
            if(condition.level == 1)
                fprintf(fid, '\t category {\n');
                fprintf(fid, '\t\t event %d\n', condition.event.code);
                fprintf(fid, '\t\t tmin %d\n', study.mne.start / 1000);
                fprintf(fid, '\t\t tmax %d\n', study.mne.stop / 1000);
                if(study.mne.basestart < study.mne.basestop)
                    fprintf(fid, '\t\t bmin %d\n', study.mne.basestart / 1000);
                    fprintf(fid, '\t\t bmax %d\n', study.mne.basestop / 1000);
                end
                fprintf(fid, '\t\t name %s\n', condition.event.desc);
                fprintf(fid, '\t }\n');
            end % if this is a primary condition
        end % for all conditions
        
        fprintf(fid, '}\n');
        fclose(fid);
        
        % Write Covariance File
        
        cov_file = sprintf('%s/%s_%s.cov',...
            dir_cmd, subject.name, block);
        fid = fopen(cov_file, 'w');
        
        fprintf(fid, 'cov {\n');
        fprintf(fid, '\t outfile %s\n',...
            gps_filename(subject, 'mne_cov_block', ['block=' block]));
        fprintf(fid, '\t eventfile %s\n',...
            gps_filename(subject, 'meg_events_grouped_block', ['block=' block]));
        fprintf(fid, '\t logfile %s\n',...
            gps_filename(subject, 'mne_cov_log_block', ['block=' block]));
        fprintf(fid, '\t gradReject %.2d\n', study.mne.gradreject);
        fprintf(fid, '\t magReject %.2d\n', study.mne.magreject);
        if(study.mne.eogreject > 0)
            fprintf(fid, '\t eogReject %d\n', study.mne.eogreject);
        else
            fprintf(fid, '\t #eogReject 150e-6\n');
        end
        fprintf(fid, '\t keepsamplemean\n');
        fprintf(fid, '\t name %s_%s\n', subject.name, block);
        
        % For each condition
        for i_condition = 1:length(study.conditions);
            condition = study.conditions{i_condition};
            condition = gpsa_parameter(condition);
            
            if(condition.level == 1)
                fprintf(fid, '\t def {\n');
                fprintf(fid, '\t\t event %d\n', condition.event.code);
                fprintf(fid, '\t\t tmin %f\n', study.mne.noisestart / 1000);
                fprintf(fid, '\t\t tmax %f\n', study.mne.noisestop / 1000);
                if(study.mne.noisebasestart < study.mne.noisebasestop)
                    fprintf(fid, '\t\t basemin %f\n', study.mne.noisebasestart / 1000);
                    fprintf(fid, '\t\t basemax %f\n', study.mne.noisebasestop / 1000);
                end
                fprintf(fid, '\t\t name %s\n', condition.event.desc);
                fprintf(fid, '\t }\n');
            end % If this is a primary condition
        end % For each condition
        
        fprintf(fid, '}\n');
        fclose(fid);
        
    end % For each block
    
    
    %% 2) Combine Data into Average and Covariance Files
    
    % Write the long command into a file
    commandfile = sprintf('%s/avewaves_command.txt',...
       dir_cmd);
    fid = fopen(commandfile, 'w');

    %% Added an explicit reference to mnehome. -tsg
    fprintf(fid, '%s/bin/mne_process_raw --lowpass 50 \\\n', state.mnehome); % 50 not 60 now
    
    % For each block
    for i_block = 1:length(subject.blocks)
        block = subject.blocks{i_block};
        
        fprintf(fid, ' --raw %s \\\n',...
            gps_filename(subject, 'meg_scan_block', ['block=' block]));
        fprintf(fid, ' --ave %s/%s_%s.ave \\\n',...
            dir_cmd, subject.name, block);
        fprintf(fid, ' --save %s \\\n',...
            gps_filename(subject, 'meg_scan_filtered_block', ['block=' block]));
        fprintf(fid, ' --cov %s/%s_%s.cov \\\n',...
            dir_cmd, subject.name, block);
    end % for each block
    
    % If there are multiple blocks, make the grand average
    if(length(subject.blocks) > 1)
        fprintf(fid, ' --gave %s \\\n', subject.mne.avefile);
        fprintf(fid, ' --gcov %s \\\n', subject.mne.covfile);
    end
    
    subject.mne.avefile = gps_filename(subject, 'mne_ave_fif');
    subject.mne.covfile = gps_filename(subject, 'mne_cov_fif');
    
    fprintf(fid, ' --proj %s --projon\n',...
        subject.meg.projfile);
    
    fclose(fid);
    
    % Process this command
    unix_command = sprintf('source %s', commandfile);
    unix(unix_command);
    
    % If there is only one block, copy it's files to the
    if(length(subject.blocks) == 1)
        copyfile(gps_filename(subject, 'mne_ave_block', ['block=' block]), subject.mne.avefile);
        copyfile(gps_filename(subject, 'mne_cov_block', ['block=' block]), subject.mne.covfile);
    end
    
    %% Emptyroom Covariance
    % If There is an emptyroom file, make a covariance average out of that
    
    emptyroom_covfile = gps_filename(subject, 'meg_scan_emptyroom');
    emptyroom_cov_fif = gps_filename(subject, 'mne_cov_emptyroom_fif');
    
    if(exist(emptyroom_covfile, 'file'))
        tlocal = tic;
        
        % Eve file
        cov_file = sprintf('%s/%s_emptyroom.cov',...
            dir_cmd, subject.name);
        fid = fopen(cov_file, 'w');
        
        fprintf(fid, 'cov {\n');
        fprintf(fid, '\t outfile %s\n',...
            emptyroom_cov_fif);
        fprintf(fid, '\t logfile %s/%s_emptyroom_cov.log\n',...
            dir_logs, subject.name);
        fprintf(fid, '\t gradReject %.2d\n', study.mne.gradreject);
        fprintf(fid, '\t magReject %.2d\n', study.mne.magreject);
        if(study.mne.eogreject > 0)
            fprintf(fid, '\t eogReject %d\n', study.mne.eogreject);
        else
            fprintf(fid, '\t #eogReject 150e-6\n');
        end
        fprintf(fid, '\t name %s_emptyroom\n', subject.name);
        
        fprintf(fid, '\t def {\n');
        fprintf(fid, '\t\t tmin %f\n', 30);
        fprintf(fid, '\t\t tmax %f\n', 120);
        fprintf(fid, '\t }\n');
        
        fprintf(fid, '}\n');
        fclose(fid);
        
        % Fif File
        
        commandfile = sprintf('%s/emptyroom_cov_command.txt',...
            dir_cmd);
        fid = fopen(commandfile, 'w');
        
        fprintf(fid, 'mne_process_raw --lowpass 50 \\\n');
        
        fprintf(fid, ' --raw %s \\\n',...
            emptyroom_covfile);
        fprintf(fid, ' --cov %s/%s_emptyroom.cov \\\n',...
            dir_cmd, subject.name);
        
        fprintf(fid, ' --proj %s --projon\n',...
            subject.meg.projfile);
        fclose(fid);
        
        unix_command = sprintf('source %s', commandfile);
        unix(unix_command);
        
        gpsa_log(state, toc(tlocal), unix_command);
        
        % Change the subject covariance file if there is an emptyroom
        if(isfield(study.mne, 'flag_emptyroom') && study.mne.flag_emptyroom)
            subject.mne.covfile = emptyroom_cov_fif;
        end
    end
    
    % Record the process
    gpsa_parameter(state, subject);
    gpsa_log(state, toc(tbegin));
    
end % If we should do the function

%% Add to the report concerning the progress

if(~isempty(strfind(operation, 'p')))
    % Prerequisites gpsa_meg_coreg, gpsa_meg_eveproc, and gpsa_meg_eog
    subject = gpsa_parameter(state, state.subject);
    report.ready = mean([~~exist(subject.mri.corfile, 'file') &&...
        ~strcmp(subject.mri.corfile(end-6 : end), 'COR.fif') ...
        ~isempty(subject.meg.projfile) && ...
        subject.meg.projfile(end) ~= '/' && ...
        ~~exist(subject.meg.projfile, 'file') ...
        max(length(dir(gps_filename(subject, 'meg_events_grouped_gen'))) / length(subject.blocks), 1)]);
    report.progress = mean([~~exist(subject.mne.avefile, 'file') ...
        ~~exist(subject.mne.covfile, 'file') ...
        max(length(dir(gps_filename(subject, 'meg_scan_filtered_gen'))) / length(subject.blocks), 1)]);
    report.finished = report.progress == 1;
end

%% Prepare the report and output

if(nargout == 1 && exist('report', 'var'));
    varargout{1} = report;
end

end % function
