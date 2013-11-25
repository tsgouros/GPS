function rois_data_subject_load(GPSR_vars)
% Loads the selected subject on the study list
%
% Author: Conrad Nied
%
% Input: The Granger Processing Stream ROIs handle
% Output: none, affects the GUI
%
% Date Created: 2012.06.14
% Last Modified: 2012.06.20
% 2012.10.09 - Superficially adapted to GPS1.7
% 2013.04.29 - GPS1.8 Updated variables to new organization
% 2013.06.28 - Interprets the average subject
% 2013.07.10 - Improved average lookup

subjects = get(GPSR_vars.data_subject_list, 'String');
i_subject = get(GPSR_vars.data_subject_list, 'Value');
GPSR_vars.subject = subjects{i_subject};

study = gpsr_parameter(GPSR_vars, GPSR_vars.study);
subject = gpsr_parameter(GPSR_vars, GPSR_vars.subject);
if(isempty(subject))
    subject.name = GPSR_vars.subject;
    subject.mri.dir = sprintf('%s/%s', study.mri.dir, subject.name);
end

%% Load Brain

% Prepare Structure
brain = struct('N',0,'N_L',0,'N_R',0,...
    'pialcoords', [], 'infcoords', [], 'origcoords', [],...
    'curv',[], 'lface', [], 'rface', []);%,...
%     'MNE', [], 'PLV', [],...
%     'decIndices', [], 'decN', 0, 'decN_L', 0, 'decN_R', 0);

% Original Coordinates

% Left
filename = sprintf('%s/surf/lh.orig', subject.mri.dir);
[lorigcoords, ~] = read_surf(filename); % function from Fa-Hsuan
lorigcoords = lorigcoords(:,1:3);
brain.N_L = length(lorigcoords);

% Right
filename = sprintf('%s/surf/rh.orig', subject.mri.dir);
[rorigcoords, ~] = read_surf(filename); % function from Fa-Hsuan
rorigcoords = rorigcoords(:,1:3);
brain.N_R = length(rorigcoords);
brain.N = brain.N_L + brain.N_R;

brain.origcoords = [lorigcoords; rorigcoords];

% Pial Surface Coordinates and Faces

% Left
filename = sprintf('%s/surf/lh.pial', subject.mri.dir);
% filename = [super_directory '/' study '/subjects/' subject '/surf/lh.pial'];
[lcoords, face] = read_surf(filename); % function from Fa-Hsuan
face = face(:,1:3)+1; %shift zero-based dipole indices to 1-based dipole indices
lcoords = lcoords(:,1:3);
brain.lface = face;

% Right
filename = sprintf('%s/surf/rh.pial', subject.mri.dir);
% filename = [super_directory '/' study '/subjects/' subject '/surf/rh.pial'];
[rcoords, face] = read_surf(filename); % function from Fa-Hsuan
face = face(:,1:3)+1; %shift zero-based dipole indices to 1-based dipole indices
rcoords = rcoords(:,1:3);
brain.rface = face;

brain.pialcoords = [lcoords; rcoords];

% Curvature

% Left
filename = sprintf('%s/surf/lh.curv', subject.mri.dir);
% filename = [super_directory '/' study '/subjects/' subject '/surf/lh.curv'];
lcurv = inverse_read_curv_new(filename); % function from Fa-Hsuan

% Right
filename = sprintf('%s/surf/rh.curv', subject.mri.dir);
% filename = [super_directory '/' study '/subjects/' subject '/surf/rh.curv'];
rcurv = inverse_read_curv_new(filename); % function from Fa-Hsuan
brain.curv = [lcurv; rcurv];

% Inflated Coordinates

% Left
filename = sprintf('%s/surf/lh.inflated', subject.mri.dir);
% filename = [super_directory '/' study '/subjects/' subject '/surf/lh.inflated'];
[linfcoords, ~] = read_surf(filename); % function from Fa-Hsuan
linfcoords = linfcoords(:,1:3);

% Right
filename = sprintf('%s/surf/rh.inflated', subject.mri.dir);
% filename = [super_directory '/' study '/subjects/' subject '/surf/rh.inflated'];
[rinfcoords, ~] = read_surf(filename); % function from Fa-Hsuan
rinfcoords = rinfcoords(:,1:3);

brain.infcoords = [linfcoords; rinfcoords];

% Automated Parcellation

% Left
filename = sprintf('%s/label/lh.aparc.annot', subject.mri.dir);
% filename = [super_directory '/' study '/subjects/' subject '/label/lh.aparc.annot'];
[~, label, colortable] = read_annotation(filename);
aparctable = colortable.table;
% allVerts.aparctext = colortable.struct_names;
brain.aparcCmap = colortable.table(:,1:3)/255;
laparci = ones(brain.N_L,1);

for i = 1:length(aparctable)
    apr = aparctable(i,5);
    laparci(label == apr) = i;
end

% Right
filename = sprintf('%s/label/rh.aparc.annot', subject.mri.dir);
% filename = [super_directory '/' study '/subjects/' subject '/label/rh.aparc.annot'];
[~, label, colortable] = read_annotation(filename);
aparctable = colortable.table;
raparci = ones(brain.N_R,1);

for i = 1:length(aparctable)
    apr = aparctable(i,5);
    raparci(label == apr) = i;
end

brain.aparcI = [laparci; raparci];

% Area Labels
% load([GPSR_vars.savedir '/aparc_labels.mat']);
al = load('aparc_labels.mat');
brain.aparcText = al.aparc_labels(:, 1);
brain.aparcShort = al.aparc_labels(:, 2);

%% Save and set

% Save to datafig
setappdata(GPSR_vars.datafig, 'brain', brain);
guidata(GPSR_vars.data_subject_list, GPSR_vars);

% % Draw
% rois_draw(GPSR_vars);
% GPSR_vars = guidata(GPSR_vars.data_subject_list);

%% Conditions List

% Look through data directory and load entries that are studies
conditions = study.conditions;
set(GPSR_vars.data_condition_list, 'String', conditions);

% Pick the study
if(find(strcmp(conditions, GPSR_vars.condition)))
    i_condition = find(strcmp(conditions, GPSR_vars.condition));
else
    i_condition = 1;
end
set(GPSR_vars.data_condition_list, 'Value', i_condition);

rois_data_condition_load(GPSR_vars);

end % function