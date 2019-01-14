function gps_labels2annot(varargin)
% Converts labels to an annotation / parcellation file
%
% Author: A. Conrad Nied (conrad@martinos.org)
%         with help from Freesurfer functions
%
% Changelog:
% 2013.05.24 - Created in GPS1.8
% 2013.06.25 - Chagned GowLab tag to GPS and integrated this function with
% gpsa_granger_rois
% 2013.07.10 - Handles average subject from condition now

%% Parameters

% Get the GPS state
[state, directory] = gpsa_inputs(varargin);

% Get study/condition parameters
study = gpsa_parameter(state, state.study);
condition = gpsa_parameter(state, state.condition);
if(~strcmp(state.subject, condition.cortex.brain))%study.granger.singlesubject)
    subject = gpsa_parameter(state, state.subject);
else
    subject.name = condition.cortex.brain;
    subject.mri.dir = sprintf('%s/%s', study.mri.dir, subject.name);
end

%% Get Label names

% Get the label directory if not already specified
if(~exist('directory', 'var') || strcmp(directory, 'c') || strcmp(directory, 'cp'))
    if(~strcmp(state.subject, condition.cortex.brain))
        directory = sprintf('%s/rois/%s/%s', study.granger.dir, condition.cortex.roiset, subject.name);
    else
        directory = sprintf('%s/rois/%s', study.granger.dir, condition.cortex.roiset);
    end % Whether we are doing this on a single subject
end

dir_annot = [directory '/annot'];
if(~exist(dir_annot, 'dir'))
    mkdir(dir_annot);
else
    rmdir(dir_annot, 's');
    mkdir(dir_annot);
end

% Get label names
labels = dir([directory '/*.label']);
labels = {labels.name};
labels_name = labels;
labels_area = labels;
labels_annot = labels;
labels_num = zeros(length(labels), 1);

% Sanitize the label names to reflect GPS1.8 standards
for i_label = 1:length(labels)
    label = labels{i_label};
    old_label = label;
    
    % Make sure the hemisphere is followed by a dash
    if(label(2) == '_')
        label(2) = '-';
        labels{i_label} = label;
    end
    
%     % And clean up numbers from labels
    underscore = find(label == '_');
%     if(~isempty(underscore))
%         secondinstance = label;
%         secondinstance(underscore + 1) = '2';
%         if(~sum(strcmp(secondinstance, labels)))
%             old_label = label;
%             label(underscore:underscore + 1) = [];
%             labels{i_label} = label;
%             movefile([directory '/' old_label], [directory '/' label]);
%         end
%     end
    labels_name{i_label} = label(1:end-9);
    labels_area{i_label} = label(1:underscore - 1);
    labels_num(i_label) = str2double(label(underscore + 1 : end - 9));
    labels_annot{i_label} = sprintf('%s.%s.label', label(end-7:end-6), label(1:end-9));
    
    copyfile([directory '/' old_label], [dir_annot '/' labels_annot{i_label}]);
end % for all labels

%% Create Coloring

% Load default colortable file
colortable_original = importdata('FSAparcDesikanColorLUT.txt', ' ', 3);

% Create a colortable file
colortable_filename_lh = sprintf('%s/label/lh.GPS_%s_ColorLUT.ctab', subject.mri.dir, condition.cortex.roiset);
colortable_filename_rh = sprintf('%s/label/rh.GPS_%s_ColorLUT.ctab', subject.mri.dir, condition.cortex.roiset);
fid_lh = fopen(colortable_filename_lh, 'w');
fid_rh = fopen(colortable_filename_rh, 'w');
fprintf(fid_lh, '# %s %s Left Hemisphere Regions of Interest Atlas Color Lookup Table\n\n', subject.name, condition.name);
fprintf(fid_rh, '# %s %s Right Hemisphere Regions of Interest Atlas Color Lookup Table\n\n', subject.name, condition.name);
fprintf(fid_lh, '%-5s %-25s %-3s %-3s %-3s %-3s\n', '# No.', 'Label Name:', 'R', 'G', 'B', 'A');
fprintf(fid_rh, '%-5s %-25s %-3s %-3s %-3s %-3s\n', '# No.', 'Label Name:', 'R', 'G', 'B', 'A');
labelstr_lh = '';
labelstr_rh = '';

i_label_l = 0;
i_label_r = 0;

for i_label = 1:length(labels)
    area = labels_area{i_label};
    i_lookup = find(strcmp(area, colortable_original.textdata(4:end, 2)));
    color = colortable_original.data(i_lookup, :); %#ok<FNDSB>
    
    % Get the color and modulate its chroma and luna if it isn't the first
    % of the area
    R = color(1)/255; G = color(2)/255; B = color(3)/255; A = color(4);
    [H, C, Y] = rgb2hcy(R, G, B);
    num = labels_num(i_label) - 1;
    C = min(max(C + 0.3 * sin(num), 0), 1);
    Y = min(max(Y + 0.3 * sin(num*5), 0), 1);
    [R, G, B] = hcy2rgb(H, C, Y);
    R = min(max(round(R*255), 0), 255);
    G = min(max(round(G*255), 0), 255);
    B = min(max(round(B*255), 0), 255);
    
    if(area(1) == 'L')
        %         labelstr_lh = sprintf('%s --l %s', labelstr_lh, labels_annot{i_label});
        %     else
        %         labelstr_rh = sprintf('%s --l %s', labelstr_rh, labels_annot{i_label});
        i_label_l = i_label_l + 1;
        fprintf(fid_lh, '%04d  %-25s %3d %3d %3d %3d\n', i_label_l, labels_name{i_label}, R, G, B, A);
        labelstr_lh = sprintf('%s --l %s/%s', labelstr_lh, dir_annot, labels_annot{i_label});
    else
        i_label_r = i_label_r + 1;
        fprintf(fid_rh, '%04d  %-25s %3d %3d %3d %3d\n', i_label_r, labels_name{i_label}, R, G, B, A);
        labelstr_rh = sprintf('%s --l %s/%s', labelstr_rh, dir_annot, labels_annot{i_label});
    end
end

fclose(fid_lh);
fclose(fid_rh);

%% Create Annotation

% Remove previous annotation
filename = sprintf('%s/label/lh.%s.annot', subject.mri.dir, condition.name);
if(exist(filename, 'file')); delete(filename); end
filename = sprintf('%s/label/rh.%s.annot', subject.mri.dir, condition.name);
if(exist(filename, 'file')); delete(filename); end

% olddir = cd(dir_annot);
%% Added explicit reference to state.fshome -ts
unix_command = sprintf('%s/bin/mris_label2annot --ctab %s%s --s %s --a %s --h lh', state.fshome, colortable_filename_lh, labelstr_lh, subject.name, condition.cortex.roiset);
unix(unix_command);
unix_command = sprintf('%s/bin/mris_label2annot --ctab %s%s --s %s --a %s --h rh', state.fshome, colortable_filename_rh, labelstr_rh, subject.name, condition.cortex.roiset);
unix(unix_command);
% cd(olddir);
% unix_command = sprintf('mris_label2annot --ctab %s --ldir %s --s %s --a %s --h lh', colortable_filename, dir_annot, subject.name, condition.cortex.roiset);
% unix(unix_command)
% unix_command = sprintf('mris_label2annot --ctab %s --ldir %s --s %s --a %s --h rh', colortable_filename, dir_annot, subject.name, condition.cortex.roiset);
% unix(unix_command)

end % function
