function rois_save_labels(GPSR_vars)
% Saves the labels for the points made into ROIs
%
% Author: Conrad Nied
%
% Label saving is based on mne_write_label_file by the Martinos folks
% Date created: 2012.06.28
% Last Modified: 2012.06.28
% 2012.10.17 - Doesn't save the sim maps because they are HUGE

fprintf('Saving labels\n');

%% Get Parameters
files  = getappdata(GPSR_vars.datafig, 'files');
brain  = getappdata(GPSR_vars.datafig, 'brain');
points = getappdata(GPSR_vars.datafig, 'points');

%% Archive any old labels in the roi directory

date = datestr(now, 'yymmdd_hhMMss');
oldfiles = dir([files.roidir '/*.label']);

if(~isempty(oldfiles))
    fprintf('\tArchiving old labels\n');
    
    archive_dir = sprintf('%s/archive_%s/', files.roidir, date);
    [~, ~, ~] = mkdir(archive_dir);
    
    % Move all label files
    unix_command = sprintf('mv %s/*.label %s', files.roidir, archive_dir);
    unix(unix_command);
    
    % Move point information file
    unix_command = sprintf('mv %s/points.mat %s', files.roidir, archive_dir);
    unix(unix_command);
    unix_command = sprintf('mv %s/all_rois.png %s', files.roidir, archive_dir);
    unix(unix_command);
    
end % If we found files

%% Generate and save label files

fprintf('\tSaving new labels\n\t');


for i_point = 1:length(points)
    point = points(i_point);
    
    if(point.ROI)
        % Define Label
        label.pos = brain.origcoords(point.vertices, :);
        label.vertices = point.vertices - 1; % 0 based
        if(point.hemi == 'R'); label.vertices = label.vertices - brain.N_L; end

        comment = sprintf('Region of Interest made using GPS_rois.m based on vertex %d on %s',...
            point.index, date);
        N_vertices = length(point.vertices);
        vertex_offset = -1 - (point.hemi == 'R') * brain.N_L;

        % Save
        filename = sprintf('%s/%s-%sh.label', files.roidir, point.name, point.hemi + 'a' - 'A');
        [fid, ~] = fopen(filename, 'w');
        fprintf(fid, '# %s\n', comment);
        fprintf(fid, '%d\n',   N_vertices);
        for i_vert = 1:N_vertices
           fprintf(fid,'%d %.2f %.2f %.2f %f\n',...
               point.vertices(i_vert) + vertex_offset,...
               brain.origcoords(point.vertices(i_vert), :),...
               point.sim(point.vertices(i_vert)));
        end
        fclose(fid);

        fprintf('.');
    end % If it is an ROI
end % For each point

points = rmfield(points, 'sim');

save([files.roidir '/points.mat'], 'points', 'date');

fprintf('\nDone saving labels\n\n');

%% Take snapshot (will want to change this later)

frame = getframe(GPSR_vars.axes_brain);
filename = sprintf('%s/all_rois.png', files.roidir);
imwrite(frame.cdata, filename, 'png');

end % function