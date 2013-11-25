function varargout = rois_talairach(GPS_vars)
% Retrieves the Talairach coordinates from a set of labels
%
% Author: Conrad Nied
%
% Date Created 2012.09.07
% Last Modified: 2012.09.13

try
    %% Get Parameters
    tbegin = tic;
    GPS_vars.function = 'rois_talairach';
    
    study = data_load(GPS_vars, GPS_vars.study);
    condition = data_load(GPS_vars, GPS_vars.condition);
    
    brain = data_loadroiset(GPS_vars);
    
    %% Get central ROI points from the labels
    folder = [condition.granger.roidir '/' GPS_vars.subject];
    if(strcmp(GPS_vars.subject, study.average_name));
        folder = condition.granger.roidir;
    else
        folder = [condition.granger.roidir '/' GPS_vars.subject];
    end % Average or subject?
    files = dir([folder '/*.label']);
    
    rois = struct('filename', '', 'name', '', 'hemi', '',...
        'centroid', []);
    
    for i_ROI = 1:length(files);
        roi.filename = [condition.granger.roidir '/' files(i_ROI).name];
        filename_point = find(files(i_ROI).name == '.'); 
        roi.name = files(i_ROI).name(1:filename_point - 4);
        roi.hemi = roi.name(1);
        
        data = importdata(roi.filename, ' ', 2);

        if(strfind(data.textdata{1}, 'GPS_rois.m'))
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
    
    Alt_vars = GPS_vars;
    Alt_vars.subject = 'fsaverage';
    brain_fsave = data_loadroiset(Alt_vars);
    
    if(nargout > 0)
        centroids = [rois.centroid];
        coordinates = brain_fsave.pialcoords(centroids, :);
        varargout{1} = coordinates;
        if(nargout > 1)
            varargout{2} = {rois.name};
        end
    end
    
    fprintf('%16s\t%6s\t%6s\t%6s\n', 'ROI', 'X', 'Y', 'Z');
    for i_ROI = 1:length(rois)
        coords = brain_fsave.pialcoords(rois(i_ROI).centroid, :);
        fprintf('%16s\t%3.2f\t%3.2f\t%3.2f\n', rois(i_ROI).name, coords);
    end % for each ROI
    
    %% Create a label from this and morph it into fsaverage
%     folder = sprintf('%s/talairach', folder);
%     if(~exist(folder, 'dir')); mkdir(folder); end
%     
%     % Left
%     filename = sprintf('%s/allrois-lh.label', folder);
%     [fid, ~] = fopen(filename, 'w');
%     fprintf(fid, '# List of centroids for %s %s\n',...
%         study.name, condition.name);
%     fprintf(fid, '%d\n',...
%         sum([rois.hemi] == 'L'));
%     
%     for i_ROI = find([rois.hemi] == 'L')
%        roi = rois(i_ROI);
%        fprintf(fid,'%d %.2f %.2f %.2f %f\n',...
%            roi.centroid,...
%            brain.origcoords(roi.centroid + 1, :),...
%            i_ROI);
%     end % for each left ROI
%     
%     % Right
%     filename = sprintf('%s/allrois-rh.label', folder);
%     [fid, ~] = fopen(filename, 'w');
%     fprintf(fid, '# List of centroids for %s %s\n',...
%         study.name, condition.name);
%     fprintf(fid, '%d\n',...
%         sum([rois.hemi] == 'R'));
%     
%     for i_ROI = find([rois.hemi] == 'R')
%        roi = rois(i_ROI);
%        fprintf(fid,'%d %.2f %.2f %.2f %f\n',...
%            roi.centroid,...
%            brain.origcoords(roi.centroid + 1 + brain.N_L, :),...
%            i_ROI);
%     end % for each left ROI
    
%     unix_command = sprintf('mne_morph_labels --from %s --to %s --labeldir %s --smooth 5',...
%             study.average_name, 'fsaverage', folder);
%     [~, ~] = unix(unix_command);
    
    %% Load the talairach coordinates from the fsaverage label'
    
%     coordinates = [0 0 0];

catch error_desc
    email_support(error_desc);
    keyboard
end % try-catch

end % function