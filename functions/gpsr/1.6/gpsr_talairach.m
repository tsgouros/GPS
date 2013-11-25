function varargout = gpsr_talairach(varargin)
% Retrieves the Talairach coordinates from a set of labels
%
% Author: Conrad Nied
%
% Changelog:
% 2012.09.07: Created as GPS1.6/rois_talairach.m
% 2012.09.13: Last modified as rois_talairach.m
% 2012.12.07: Converted to GPS1.7/gpsr_talairach.m
% 2013.01.31: Emails the user now

%% Get Parameters

tbegin = tic;
[state, operation] = gpsa_inputs(varargin);
state.function = 'gpsr_talairach';
study = gpsa_parameter(state, state.study);
subset = gpsa_parameter(state, state.subset);

% Load Brains
filename = sprintf('%s/%s/brain.mat', study.mri.dir, state.subject);
brain = load(filename);

filename = sprintf('%s/%s/brain_fsaverage.mat', study.mri.dir, study.average_name);
if(~exist(filename, 'file'))
    fsstate = state;
    fsstate.subject = 'fsaverage';
    gpsa_mri_brain2mat(state);
end
brain_fsave = load(filename);

%% Get central ROI points from the labels
if(strcmp(state.subject, study.average_name));
    folder = subset.cortex.roidir;
else
    folder = [subset.cortex.roidir '/' state.subject];
end % Average or subject?
files = dir([folder '/*.label']);

rois = struct('filename', '', 'name', '', 'hemi', '',...
    'centroid', []);

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

% Open file
filename = sprintf('%s/talairach_coordinates.txt', folder);
fid = fopen(filename, 'w');

% Write coordinates to file and standard out
fprintf(fid, '%s %s %s Talairach Coordinates\n', state.study, state.subject, state.subset);
fprintf(fid, '\tMade %s\n', datestr(now, 'yymmdd'));
fprintf(fid, '%16s\t%6s\t%6s\t%6s\n', 'ROI', 'X', 'Y', 'Z');
for i_ROI = 1:length(rois)
    coords = brain_fsave.pialcoords(rois(i_ROI).centroid, :);
    fprintf(fid, '%16s\t%3.2f\t%3.2f\t%3.2f\n', rois(i_ROI).name, coords);
end % for each ROI

% Closefile
fclose(fid);

end % function