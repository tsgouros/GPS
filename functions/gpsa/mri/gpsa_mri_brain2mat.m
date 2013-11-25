function varargout = gpsa_mri_brain2mat(varargin)
% Load's subject brain from multiple files and saves it into one
%
% Author: A. Conrad Nied (conrad.logos@gmail.com)
%
% Changelog:
% 2011-10-04 Originally created as GPS1.6(-)/data_loadroiset.m
% 2012-09-13 Last modified in GPS1.6(-)
% 2012-10-09 Updated to GPS1.7 format
% 2012-10-11 Doesn't do decimated space for average subject
% 2012-12-07 Accomodates FSaverage and saves it with t
% 2013-04-11 GPS 1.8, Updated the status check to the new system
% 2013-04-24 Changed subset/subsubset to condition/subset
% 2013-06-25 Gets annotations from all conditions possible
% 2013-07-03 No longer investigates the final status check and can now
%     output the brain dataset as well by specifying o as the operation
% 2013-08-13 Explicitly lists the state in the gpsa_parameter calls

%% Input

[state, operation] = gpsa_inputs(varargin);

%% Prepare a report on the type or progress of the data

if(~isempty(strfind(operation, 't')))
    report.spec_subj = 1; % Subject specific?
    report.spec_cond = 0; % Condition specific?
end

%% Execute the process

if(~isempty(strfind(operation, 'c')) || ~isempty(strfind(operation, 'o')))
    
    study = gpsa_parameter(state, state.study);
    subject = gpsa_parameter(state, state.subject);
    condition = gpsa_parameter(state, state.condition);
    state.function = 'gpsa_mri_brain2mat';
    tbegin = tic;
    
    %% Prepare Structure
    dataset = struct('N', 0, 'N_L', 0, 'N_R', 0,...
        'pialcoords', [], 'infcoords', [], 'origcoords', [],...
        'curv',[], 'lface', [], 'rface', [],...
        'decIndices', [], 'decN', 0, 'decN_L', 0, 'decN_R', 0);
    dataset.name = 'brain';
    
    %% Load Parameter Files
    
    if(isempty(subject))
        subject.name = state.subject;
        subject.mri.dir = sprintf('%s/%s', study.mri.dir, subject.name);
    end
    
    fprintf('Loading %s''s brain\n\t', subject.name);
    
    %% Original Coordinates
    
    fprintf('orig ');
    
    % Left
    filename = sprintf('%s/surf/lh.orig', subject.mri.dir);
    [~, lorigcoords, ~] = evalc('read_surf(filename);'); % function from Fa-Hsuan
    lorigcoords = lorigcoords(:, 1:3);
    dataset.N_L = length(lorigcoords);
    
    % Right
    filename = sprintf('%s/surf/rh.orig', subject.mri.dir);
    [~, rorigcoords, ~] = evalc('read_surf(filename);'); % function from Fa-Hsuan
    rorigcoords = rorigcoords(:, 1:3);
    dataset.N_R = length(rorigcoords);
    dataset.N = dataset.N_L + dataset.N_R;
    
    dataset.origcoords = [lorigcoords; rorigcoords];
    
    %% Pial Surface Coordinates and Faces
    
    fprintf('pial ');
    
    % Left
    filename = sprintf('%s/surf/lh.pial', subject.mri.dir);
    [lcoords, face] = read_surf(filename); % function from Fa-Hsuan
    face = face(:, 1:3) + 1; %shift zero-based dipole indices to 1-based dipole indices
    lcoords = lcoords(:,1:3);
    dataset.lface = face;
    
    % Right
    filename = sprintf('%s/surf/rh.pial', subject.mri.dir);
    [rcoords, face] = read_surf(filename); % function from Fa-Hsuan
    face = face(:, 1:3) + 1; %shift zero-based dipole indices to 1-based dipole indices
    rcoords = rcoords(:,1:3);
    dataset.rface = face;
    
    dataset.pialcoords = [lcoords; rcoords];
    
    %% Inflated Coordinates
    
    fprintf('inf ');
    
    % Left
    filename = sprintf('%s/surf/lh.inflated', subject.mri.dir);
    [linfcoords, ~] = read_surf(filename); % function from Fa-Hsuan
    linfcoords = linfcoords(:, 1:3);
    
    % Right
    filename = sprintf('%s/surf/rh.inflated', subject.mri.dir);
    [rinfcoords, ~] = read_surf(filename); % function from Fa-Hsuan
    rinfcoords = rinfcoords(:, 1:3);
    
    dataset.infcoords = [linfcoords; rinfcoords];
    
    %% Curvature
    
    fprintf('curv ');
    
    % Left
    filename = sprintf('%s/surf/lh.curv', subject.mri.dir);
    [~, lcurv] = evalc('inverse_read_curv_new(filename);'); % function from Fa-Hsuan
    
    % Right
    filename = sprintf('%s/surf/rh.curv', subject.mri.dir);
    [~, rcurv] = evalc('inverse_read_curv_new(filename);'); % function from Fa-Hsuan
    dataset.curv = [lcurv; rcurv];
    
    %% Automated Parcellation
    
    fprintf('aparc ');
    
    % Left
    filename = sprintf('%s/label/lh.aparc.annot', subject.mri.dir);
    [~, ~, label, colortable] = evalc('read_annotation(filename);');
    aparctable = colortable.table;
    % allVerts.aparctext = colortable.struct_names;
    dataset.aparcCmap = colortable.table(:,1:3)/255;
    laparci = zeros(dataset.N_L,1);
    
    for i = 1:length(aparctable)
        apr = aparctable(i,5);
        laparci(label == apr) = i;
    end
    
    % Right
    filename = sprintf('%s/label/rh.aparc.annot', subject.mri.dir); %#ok<*NASGU>
    [~, ~, label, colortable] = evalc('read_annotation(filename);');
    aparctable = colortable.table;
    raparci = zeros(dataset.N_R,1);
    
    for i = 1:length(aparctable)
        apr = aparctable(i,5);
        raparci(label == apr) = i;
    end
    
    dataset.aparcI = [laparci; raparci];
    dataset.aparcI(dataset.aparcI == 0) = 1;
    
    % Area Labels
    al = load('aparc_labels.mat');
    dataset.aparcText = al.aparc_labels(:,1);
    dataset.aparcShort = al.aparc_labels(:,2);
    
    %% BU Speech Lab Parcellation (if available)
    
    filename = sprintf('%s/label/lh.SLaparc17.annot', subject.mri.dir);
    if(exist(filename, 'file'))
        fprintf('SLaparc ');
        
        % Left
        [~, ~, label, colortable] = evalc('read_annotation(filename);');
        aparctable = colortable.table;
        dataset.SLaparc17.text = colortable.struct_names;
        dataset.SLaparc17.Cmap = colortable.table(:,1:3)/255;
        laparci = zeros(dataset.N_L,1);
        
        for i = 1:length(aparctable)
            apr = aparctable(i,5);
            laparci(label == apr) = i;
        end
        
        % Right
        filename = sprintf('%s/label/rh.SLaparc17.annot', subject.mri.dir); %#ok<*NASGU>
        [~, ~, label, colortable] = evalc('read_annotation(filename);');
        aparctable = colortable.table;
        raparci = zeros(dataset.N_R,1);
        
        for i = 1:length(aparctable)
            apr = aparctable(i,5);
            raparci(label == apr) = i;
        end
        
        dataset.SLaparc17.I = [laparci; raparci];
        dataset.SLaparc17.I(dataset.SLaparc17.I == 0) = 1;
 
    end % If the file exists
    
    
    %% Condition Parcellation (if available)
    
    for i_condition = 1:length(study.conditions)
        condition2 = gpsa_parameter(state, study.conditions{i_condition});
        roiset = condition2.cortex.roiset;
        filename = sprintf('%s/label/lh.%s.annot', subject.mri.dir, roiset);
        if(exist(filename, 'file') && ~isfield(dataset, roiset))
            fprintf('%sparc ', roiset);
            
            % Left
            [~, ~, label, colortable] = evalc('read_annotation(filename);');
            aparctable = colortable.table;
            dataset.(roiset).text = colortable.struct_names;
            dataset.(roiset).Cmap = colortable.table(:,1:3)/255;
            laparci = zeros(dataset.N_L,1);
            
            for i = 1:length(aparctable)
                apr = aparctable(i, 5);
                laparci(label == apr) = i;
            end
            parcN_L = length(aparctable);
            
            % Right
            filename = sprintf('%s/label/rh.%s.annot', subject.mri.dir, roiset); %#ok<*NASGU>
            [~, ~, label, colortable] = evalc('read_annotation(filename);');
            aparctable = colortable.table;
            dataset.(roiset).text = cat(1, dataset.(roiset).text, colortable.struct_names);
            dataset.(roiset).Cmap = cat(1, dataset.(roiset).Cmap, colortable.table(:,1:3)/255);
            raparci = zeros(dataset.N_R,1);
            
            for i = 1:length(aparctable)
                apr = aparctable(i,5);
                raparci(label == apr) = i + parcN_L;
            end
            
            dataset.(roiset).I = [laparci; raparci];
            dataset.(roiset).I(dataset.(roiset).I == 0) = 1;
            
        end % If the file exists
    end % for each condition/roiset
    
    %% Decimated Data from the forward solution (should find a better place for this)
    
    if(isfield(subject, 'mne') && exist(subject.mne.fwdfile, 'file'))
        fprintf('srcspace ');
        
        [~, fwd] = evalc('mne_read_source_spaces(subject.mne.fwdfile);');
        
        dataset.decIndices = [fwd(1).vertno'; fwd(2).vertno' + dataset.N_L];
        dataset.decN_L = fwd(1).nuse;
        dataset.decN_R = fwd(2).nuse;
        dataset.decN = dataset.decN_L + dataset.decN_R;
    elseif(strcmp(subject.name, condition.cortex.brain))

        actfile = gps_filename(study, condition, 'mne_stc_avesubj_lh');
        
        if(exist(actfile, 'file'))
            fprintf('srcspace ');
            
            actdata_lh = mne_read_stc_file1(actfile);
            actfile = gps_filename(study, condition, 'mne_stc_avesubj_rh');
            actdata_rh = mne_read_stc_file1(actfile);
            
            dataset.decIndices = [actdata_lh.vertices; actdata_rh.vertices + dataset.N_L];
            dataset.decN_L = length(actdata_lh.vertices);
            dataset.decN_R = length(actdata_rh.vertices);
            dataset.decN = dataset.decN_L + dataset.decN_R;
        end
    end % if getting the decimated data
    
    fprintf('Done.\n');
    
    %% Save (or output)
    if(~isempty(strfind(operation, 'c')))
        if(strcmp(subject.name, 'fsaverage'))
            savefile = sprintf('%s/%s/brain_fsaverage.mat', study.mri.dir, condition.cortex.brain);
        else
            savefile = sprintf('%s/brain.mat', subject.mri.dir);
        end
        
        save(savefile, '-struct', 'dataset');
        
        % Record the process
        gpsa_log(state, toc(tbegin));
    elseif(~isempty(strfind(operation, 'o')))
        % this throws away the type report, but we will worry about that if
        % it ever matters
        report = dataset;
    end
    
end % If we should do the function

%% Add to the report concerning the progress

if(~isempty(strfind(operation, 'p')))
    subject = gpsa_parameter(state, state.subject);
    if(isempty(subject))
        subject.name = state.subject;
        subject.type = 'subject';
        subject.mri.dir = sprintf('%s/%s', study.mri.dir, subject.name);
    end
    report.ready = ~~exist(subject.mne.fwdfile, 'file');
    report.progress = ~~exist(gps_filename(subject, 'mri_cortex_mat'), 'file');
    report.finished = report.progress == 1;
end

%% Prepare the report and output

if(nargout == 1 && exist('report', 'var'));
    varargout{1} = report;
elseif(nargout == 1)
    varargout{1} = [];
end

end % function