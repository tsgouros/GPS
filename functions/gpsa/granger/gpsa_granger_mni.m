function varargout = gpsa_granger_mni(varargin)
% Retrieves the Talairach coordinates from a set of labels
%
% Author: A. Conrad Nied (conrad.logos@gmail.com)
%
% Changelog:
% 2013.01.31 - Added to GUI, was before GPS1.7/gpsr_talairach.m
% 2013.04.11 - GPS 1.8, Updated the status check to the new system
% 2013.04.12 - Finished updating and renamed to gpsa_granger_mni.m
% 2013.04.25 - Changed subset design to condition hierarchy
% 2013.06.25 - Reverted status to previous design to avoid bugs

[state, operation] = gpsa_inputs(varargin);

%% Prepare a report on the type or progress of the data

if(~isempty(strfind(operation, 't')))
    report.spec_subj = 0; % Subject specific?
    report.spec_cond = 3; % Condition specific?
end

%% Execute the process

if(~isempty(strfind(operation, 'c')))
    
    %% Get Parameters
    
    tbegin = tic;
    state.function = 'gpsa_granger_mni';
    study = gpsa_parameter(state, state.study);
    condition = gpsa_parameter(state, state.condition);
    state.subject = condition.cortex.brain;
    
    % Load Brains
    filename = sprintf('%s/%s/brain.mat', study.mri.dir, state.subject);
    if(~exist(filename, 'file'))
        gpsa_mri_brain2mat(state);
    end
    brain = load(filename);
    
    filename = sprintf('%s/%s/brain_fsaverage.mat', study.mri.dir, condition.cortex.brain);
    if(~exist(filename, 'file'))
        fsstate = state;
        fsstate.subject = 'fsaverage';
        gpsa_mri_brain2mat(fsstate);
    end
    brain_fsave = load(filename);
    
    %% Get central ROI points from the labels
    
    folder = gps_filename(state, study, condition, 'granger_rois_set_dir');
    files = dir([folder '/*.label']);
    
    rois = struct('filename', '', 'name', '', 'hemi', '', 'centroid', []);
    
    for i_ROI = 1:length(files);
        roi.filename = [folder '/' files(i_ROI).name];
        filename_point = find(files(i_ROI).name == '.');
        roi.name = files(i_ROI).name(1:filename_point - 4);
        roi.hemi = roi.name(1);
        
        data = importdata(roi.filename, ' ', 2);
        
        if(sum(strfind(data.textdata{1}, 'GPS_rois.m')) || sum(strfind(data.textdata{1}, 'GPSr')))
            data = data.data;
            %             roi.vertices = data(:, 1) + 1;
            roi.centroid = data(1, 1)  +1;
            if(roi.hemi == 'R');
                roi.centroid = roi.centroid + brain.N_L;
            end
        else % ROI Analyzer
            data = data.data;
            %             roi.vertices = data(:, 1) + 1;
            roi.centroid = data(1, 5);
            %             if(roi.hemi == 'R');
            %                 roi.centroid = roi.centroid - brain.N_L;
            %             end
        end
        
        rois(i_ROI) = roi;
    end
    
    %% Find coordinates on FSaverage pial surface
    
    if(nargout > 0)
        centroids = [rois.centroid];
        coordinates = brain_fsave.pialcoords(centroids, :);
        varargout{1} = coordinates;
        if(nargout > 1)
            varargout{2} = {rois.name};
        end
    end
    
    % Write coordinates to file and standard out
    title = sprintf('%s %s %s MNI Coordinates', state.study, state.subject, state.condition);
    str = sprintf('%s\n\tMade %s\n', title, datestr(now, 'yyyy.mm.dd'));
    str = sprintf('%s%16s\t%6s\t%6s\t%6s\n', str, 'ROI', 'X', 'Y', 'Z');
    for i_ROI = 1:length(rois)
        coords = brain_fsave.pialcoords(rois(i_ROI).centroid, :);
        str = sprintf('%s%16s\t%3.2f\t%3.2f\t%3.2f\n', str, rois(i_ROI).name, coords);
    end % for each ROI
    
    % Write to file
    filename = gps_filename(state, study, condition, 'granger_mni_coordinates');
    fid = fopen(filename, 'w');
    
    filename
    fid
    
    fprintf(fid, str);
    fclose(fid);
    
    % Write to Std Out and Email to user
    fprintf(str);
    
    %% Wrap up
    
    % Record the process
    gpsa_log(state, toc(tbegin));
    
end % If we should do the function

%% Add to the report concerning the progress
% Not updated to current standard of file

if(~isempty(strfind(operation, 'p')))
    study = gpsa_parameter(state, state.study);
    condition = gpsa_parameter(state, state.condition);
    report.ready = ~isempty(gps_filename(state, study, condition, 'granger_rois_set_labels_gen'));
    report.progress = ~~exist(gps_filename(study, state, condition, 'granger_mni_coordinates'), 'file');
    report.finished = report.progress == 1;
end

%% Prepare the report and output

if(nargout == 1 && exist('report', 'var'));
    varargout{1} = report;
end

end % function
