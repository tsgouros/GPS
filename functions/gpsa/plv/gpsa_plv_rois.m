function varargout = gpsa_plv_rois(varargin)
% Template function for all other functions
%
% Author: A. Conrad Nied
%
% Changelog:
% 2012.10.17 - Created, based on GPS1.7/gpsa_granger_rois
% 2013.04.24 - GPS1.8 Changed subset/subsubset to condition/subset

%% Input

[state, operation] = gpsa_inputs(varargin);

%% Prepare a report on the type or progress of the data

if(~isempty(strfind(operation, 't')))
    report.spec_subj = 1; % Subject specific?
    report.spec_cond = 1; % Condition specific?
end

%% Execute the process

if(~isempty(strfind(operation, 'c')))
    
    study = gpsa_parameter(state.study);
    subject = gpsa_parameter(state.subject);
    condition = gpsa_parameter(state.condition);
    state.function = 'gpsa_plv_rois';
    tbegin = tic;
    
    % Configure
    flag_image = 1;
    
    subject_roidir = sprintf('%s/%s', condition.cortex.plvrefdir, subject.name);
    
    % Import their brain
    brain_file = sprintf('%s/brain.mat', subject.mri.dir);
%     if(study.plv.flag)
%         brain_file = sprintf('%s/brain_highres.mat', subject.mri.dir);
%     end
    brain = load(brain_file);
    
    flag_morph = 1;
    if(isfield(study.granger, 'singlesubject'))
        flag_morph = ~study.granger.singlesubject;
    end
    hemis = {'lh'; 'rh'};
    N_hemis = 2;
    
%     % Change decimated vertices to match decimated surface
%     inv_filename = subject.mne.invfile;
%     inv_filename = inv_filename(1:find(inv_filename == '/', 1, 'last'));
%     inv_filename = sprintf('%s%s_depth_meg_spacing5-inv.fif', inv_filename, subject.name);
%     inv = gpsa_mne_getinv(inv_filename);
%     brain.decIndices = [inv.src(1).vertno'; inv.src(2).vertno' + brain.N_L];
%     brain.decN_L = inv.src(1).nuse;
%     brain.decN_R = inv.src(2).nuse;
%     brain.decN = brain.decN_L + brain.decN_R;
    
    % If necessary, rewrite the labels for the ROI to be mapped on the
    % subject's brain
    if (flag_morph)
        % Remove old morphed maps
        labels = sprintf('%s/*.label', subject_roidir);
        if(~isempty(dir(labels)))
            delete(labels)
        end
        
        tlocal = tic;
        unix_command = sprintf('mne_morph_labels --from %s --to %s --labeldir %s --smooth 5',...
            study.average_name, subject.name, condition.cortex.plvrefdir);
        [~, ~] = unix(unix_command);
        gpsa_log(state, unix_command, toc(tlocal));
    end
    
%     rois.name = {};
%     rois.centroid = [];
    N_ROIs = 0;
    regions_cortical = zeros(brain.N, 1);
    activity_cortex = zeros(brain.decN, 1);
    activity_ROIs = [];
    
    % For Each Hemisphere
    for i_hem = 1:N_hemis
        hemi = hemis{i_hem};
        
        % Get the PLV Data (right now just chooses the first one...
        % change it depending which PLV ROI and frequency we are using)
        %             plvfile = sprintf('%s/stc/%s/%s*_plv-%s.stc',...
        %                 study.plv.dir, condition.name, subject.name, hemi);
        %             plvfiles = dir(plvfile);
        %             plvfile = sprintf('%s/stc/%s/%s',...
        %                 study.plv.dir, condition.name, plvfiles(1).name);
        
        if(condition.primary)
            type = 'mne';
        else
            type = 'act';
        end
%         type = 'acthighres';
        actfile = sprintf('%s/stcs/%s_%s_%s-%s.stc',...
            subject.meg.dir, subject.name, condition.name, type, hemi);
        
        actdata = mne_read_stc_file1(actfile);
        sample_times = actdata.tmin + ((1:size(actdata.data, 2)) - 1) * actdata.tstep;
        start = max(find(sample_times > condition.event.focusstart/1000, 1, 'first') - 1, 1);
        stop = min(find(sample_times < condition.event.focusstop/1000, 1, 'last') + 1, length(sample_times));
        time_focus = start:stop;
        if(strcmp(hemi, 'lh'))
            activity_cortex(1:brain.decN_L) = mean(actdata.data(:, time_focus), 2);
        else
            activity_cortex(brain.decN_L + 1 : end) = mean(actdata.data(:, time_focus), 2);
        end
        
        % Find all of the ROIs
        labels = sprintf('%s/*%s.label', subject_roidir, hemi);
        labels = dir(labels);
        
        N_hemiROIs = length(labels);
        rois_files = cell(N_hemiROIs, 1);
        ROIcents = zeros(N_hemiROIs, 1);
        
        % For each label, find the point with the highest PLV activation and
        % make this the representative of the ROI
        for i_hemiROI = 1:N_hemiROIs
            roi_file = labels(i_hemiROI).name;
            rois_files{i_hemiROI} = roi_file;
            
            % Locate the vertex with the highest PLV
            labelfile = sprintf('%s/%s', subject_roidir, roi_file);
            [activity, ~, vertices] = mne_label_time_courses(labelfile, actfile); % mid is time
            %             [max_v, max_i] = max(sum(PLV, 2)); % Find the max total PLV value
            %
            %             ROIcents(i_ROI) = vertices(max_i);
            
            % Do not repeat vertices (this is a quick not the best fix)
            [~, max_i] = sort(sum(activity(:, time_focus), 2)); % Find the max total activity value
            
            % Select only the top 30 vertices
            if(length(max_i) > 20)
                max_i = max_i(end - 20 : end); end
            vertices = vertices(max_i);
            centroid_vertex = vertices(end);
            
%             while(sum(vertices(max_i(1)) == ROIcents))
%                 max_i(1) = [];
%             end
%             centroid_vertex = vertices(max_i(1));
            ROIcents(i_hemiROI) = centroid_vertex;
            
            %% Prepare structure
            
            % Name
            roi.name = roi_file(1 : end - 9);
            roi.file = labelfile;
            
            % Features
            dashes = strfind(roi.name, '-');
            if(isempty(dashes))
                dashes = strfind(roi.name, '_');
            end
            roi.hemi = roi.name(1);
            roi.area = roi.name(dashes(1) + 1 : dashes(2) - 1);
            roi.num = str2double(roi.name(dashes(2) + 1: end));
            
            % Vertex
            if(strcmp(hemi, 'lh'))
                roi.centroid = centroid_vertex;
            else
                roi.centroid = centroid_vertex + double(brain.N_L);
            end
            
            % Decimated Vertex
            roi.decIndex = find(brain.decIndices == roi.centroid);
            if(isempty(roi.decIndex));
                roi.decIndex = find(brain.decIndices == roi.centroid + 1);
            elseif(isempty(roi.decIndex))
                error('Did not find the decimated index of the %s', roi.name);
            end
            
            % FS Parcellation
            roi.aparcI = brain.aparcI(roi.centroid);
            roi.aparc = brain.aparcShort{roi.aparcI};
            
            % Medial or Lateral?
            switch roi.area
                case {'STS', 'cMFG', 'AG', 'ITG', 'LOC', 'LOrb', 'MTG', 'Oper',...
                        'ParsOper', 'ParsTri', 'Tri', 'OrbIFG', 'Calc',...
                        'postCG', 'preCG', 'rMFG', 'SFG', 'SPC', 'STG', 'SMG',...
                        'FPol', 'TPol', 'Aud', 'Insula', 'ParsOrb'}
                    roi.side = 'L';
                case {'ParaHip','Medial', 'caCing', 'Ent', 'CC', 'Isth', 'Cun',...
                        'ParaC', 'MOrb', 'Fusi', 'pCing', 'preCun', 'raCing', 'Ling'}
                    roi.side = 'M';
                otherwise
                    roi.side = 'M';
            end
            if(roi.hemi == 'L')
                roi.vertices = vertices;
            else
                roi.vertices = vertices + brain.N_L;
            end
            
            % Add to structure
            N_ROIs = N_ROIs + 1;
            rois(N_ROIs) = roi; %#ok<AGROW>
            
            % Put in regions
            if(hemi == 'L')
                regions_cortical(vertices + 1) = N_ROIs;
            else
                regions_cortical(vertices + brain.N_L + 1) = N_ROIs;
            end
            
            % Activity
            activity_ROIs(N_ROIs, :) = activity(max_i(1), time_focus); %#ok<AGROW>
        end
        
    end % For Each Hemisphere
    
    % Display on the cortex
    
    % Visualize Maps
    if(flag_image)
        figure(1)
        clf
        set(gcf, 'Units', 'Pixels');
        set(gcf, 'Position', [10, 10, 833, 625]);
        set(gca, 'Units', 'Normalized');
        set(gca, 'Position', [.02, .02, .96, .96]);
        
        % Set parameters
        drawdata = brain;
        drawdata.act.data = activity_cortex;
        drawdata.act.p = [80 90 95];
        drawdata.regions = regions_cortical;
        drawdata.points = rois;
        
        options.overlays.name = 'act';
        options.overlays.percentiled = 'p';
        options.overlays.decimated = 1;
        options.overlays.coloring = 'h';
        options.shading = 1;
        options.curvature = 'bin';
        options.sides = {'ll', 'rl', 'lm', 'rm'};
        options.fig = gcf;
        options.axes = gca;
        options.centroids = 1;
        options.vertices = 1;
        options.labels = 1;
        options.regions = 0;
        options.regions_color = gps_colorhash((1:length(rois))')/255;
        options.labels_color = gps_colorhash((1:length(rois))')/255/4 + 0.75;
        options.vertices_color = gps_colorhash((1:length(rois))')/255/2 + 0.5;
        options.centroids_color = gps_colorhash((1:length(rois))')/255/4 + 0.25;
        
        % Draw mean activity
%         drawdata.act.data = mean(cortexdata(:, sample(condition.event.focusstart / 1000) : ...
%             sample(condition.event.focusstop / 1000)), 2);
        gps_brain_draw(drawdata, options);
        
        frame = getframe(gcf);
        filename = sprintf('%s/%s/%s_%s_plvref.png',...
            condition.cortex.plvrefdir, subject.name, subject.name, condition.name);
        imwrite(frame.cdata, filename);
        
        clear drawdata options;
    end
    
    % Summarize into a structure
    roistruct.rois = rois; %#ok<STRNU>
    
    %% Save
%     filename = sprintf('%s/%s_%s_rois.mat', subject_roidir, subject.name, condition.name);
    filename = sprintf('%s/%s_plvref.mat', subject_roidir, subject.name);
    save(filename, '-struct', 'roistruct');
    
    % Record the process
    gpsa_log(state, toc(tbegin));
    
end % If we should do the function

%% Add to the report concerning the progress

if(~isempty(strfind(operation, 'p')))
    subject = gpsa_parameter(state.subject);
    condition = gpsa_parameter(state.condition);
    if(~isempty(subject))
        % Predecessor: GPSr and mri_brain2mat
        report.ready = (double(~isempty(dir([condition.cortex.plvrefdir '/*.label']))) + ...
            double(exist(sprintf('%s/brain.mat', subject.mri.dir), 'file') == 2)) / 2;
        filename = sprintf('%s/%s/%s*plvref.mat', condition.cortex.plvrefdir,...
            subject.name, subject.name);
        report.progress = ~isempty(dir(filename));
        report.finished = report.progress == 1;
    else
        report.ready = 0;
        report.progress = 0;
        report.finished = 0;
    end
end

%% Prepare the report and output

if(nargout == 1 && exist('report', 'var'));
    varargout{1} = report;
end

end % function