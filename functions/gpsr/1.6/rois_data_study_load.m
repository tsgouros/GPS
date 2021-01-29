function rois_data_study_load(GPSR_vars)
% Loads the selected study on the study list
%
% Author: Conrad Nied
%
% Input: The Granger Processing Stream ROIs handle
% Output: none, affects the GUI
%
% Date Created: 2012.06.14
% Last Modified: 2012.06.20
% 2012.10.09 - Superficially adapted to GPS1.7
% 2013.07.10 - GPS1.8 loads mri directory subjects

%% Current Study
studies = get(GPSR_vars.data_study_list, 'String');
i_study = get(GPSR_vars.data_study_list, 'Value');
GPSR_vars.study = studies{i_study};
study = gpsr_parameter(GPSR_vars, GPSR_vars.study);
study.mri.dir = '/autofs/space/clive_001/users/adriana/OliviaData/UAG_new/MRI' %Olivia Made this hack on September 24th 2020 to to get around the problem that GPS ROIs wouldn't load the study data

%% Subjects List

% Look through the mri directory and list viable subjects
subjects = dir(study.mri.dir);
subjects = {subjects.name};
for i_subject = length(subjects):-1:1 % Exclude
    switch subjects{i_subject}
        case {'.', '..', 'morph-maps', 'lh.EC_average', 'rh.EC_average'}
            subjects(i_subject) = [];
    end
end
% subjects = [{study.average_name}; study.subjects];
set(GPSR_vars.data_subject_list, 'String', subjects);

% Pick the study
if(find(strcmp(subjects, GPSR_vars.subject)))
    i_subject = find(strcmp(subjects, GPSR_vars.subject));
else
    i_subject = 1;
end
set(GPSR_vars.data_subject_list, 'Value', i_subject);

rois_data_subject_load(GPSR_vars);
GPSR_vars = guidata(GPSR_vars.data_subject_list);

% Subject will do conditions then set

%% Update the GUI
guidata(GPSR_vars.data_study_list, GPSR_vars);

end