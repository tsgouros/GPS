function varargout = gpsa_plv_avesubj(varargin)
% Averages the MNE data for all subjects
%
% Author: A. Conrad Nied
%
% Changelog:
% 2012.11.01 - Created based on GPS1.7/gpsa_mne_avesubj.m
% 2013.02.01 - Saves a .mat file of all subjects too
% 2013.04.24 - GPS1.8 Changed subset/subsubset to condition/subset
% 2013.07.10 - Disabled

%% Input

[state, operation] = gpsa_inputs(varargin);

%% Prepare a report on the type or progress of the data

if(~isempty(strfind(operation, 't')))
    report.spec_subj = 0; % Subject specific?
    report.spec_cond = 1; % Condition specific?
end

%% Execute the process

if(~isempty(strfind(operation, 'c')))
    
    study = gpsa_parameter(state.study);
    condition = gpsa_parameter(state.condition);
    state.function = 'gpsa_plv_avesubj';
    tbegin = tic;
    
    % Make a directory for the mne files for this condition
    stcfolder = sprintf('%s/results', study.plv.dir);
    if(~exist(stcfolder, 'dir')); mkdir(stcfolder); end
    if(~exist([stcfolder '/commands'], 'dir')); mkdir([stcfolder '/commands']); end
    
    desc_filename = sprintf('%s/commands/%s_ave_desc',...
        stcfolder, condition.name);
    desc_file = fopen(desc_filename, 'w');
    
    for i_subject = 1:length(study.subjects)
        subject = gpsa_parameter(state, study.subjects{i_subject});
        
        stcfilename = sprintf('%s/subject_results/%s/%s_plv_LSTG1_40Hz_avebrain',...
            study.plv.dir, condition.name, subject.name);
        
        % Load internally to save to a grand .mat file
        lh = mne_read_stc_file([stcfilename '-lh.stc']);
        rh = mne_read_stc_file([stcfilename '-rh.stc']);
        if(i_subject == 1)
            [N_vertices, N_time] = size(lh.data);
            N_vertices = N_vertices + size(rh.data, 1);
            sample_times = 0:(N_time - 1) * lh.tstep + lh.tmin; %#ok<NASGU>
            phase_locking = zeros(N_vertices, N_time, length(study.subjects));
        end
        phase_locking(:, :, i_subject) = [lh.data; rh.data];
        
        fprintf(desc_file, 'stc %s\n',...
            stcfilename);
    end % For each subject
    
    % Save grand plv file and then clear it from memory.
    filename = sprintf('%s/%s_%s_%s_plv_LSTG1_40Hz.mat',...
        stcfolder, study.name, study.average_name, condition.name);
    save(filename, 'sample_times', 'phase_locking');
    clear phase_locking;
    
    % Average Subject MNE
    fprintf(desc_file,'\ndeststc %s/%s_%s_%s_plv_LSTG1_40Hz\n',...
        stcfolder, study.name, study.average_name, condition.name);
    unix_command = sprintf('mne_average_estimates --desc %s', desc_filename);
    unix(unix_command);
    
    % Record the process
    gpsa_log(state, toc(tbegin), unix_command);
    
end % If we should do the function

%% Add to the report concerning the progress

if(~isempty(strfind(operation, 'p')))
%     study = gpsa_parameter(state.study);
%     condition = gpsa_parameter(state.condition);
%     if(~isempty(condition))
%         % Predecessor: gpsa_plv_stcave
%         stcfilename = sprintf('%s/subject_results/%s/*_plv_LSTG1_40Hz_avebrain-lh.stc',...
%             study.plv.dir, condition.name);
%         report.ready = min(length(dir(stcfilename)) / length(study.subjects), 1);
%         filespec = sprintf('%s/results/%s_%s_%s_plv_LSTG1_40Hz*',...
%             study.plv.dir, study.name, study.average_name, condition.name);
%         report.progress = length(dir(filespec)) >= 2;
%         report.finished = report.progress == 1;
%     else
        report.ready = 0;
        report.progress = 0;
        report.finished = 0;
%     end
end

%% Prepare the report and output

if(nargout == 1 && exist('report', 'var')); 
    varargout{1} = report;
end

end % function