function gpsr_menu_cortex
% Updates GPSr based on a click in the cortex menu
%
% Author: A. Conrad Nied
%
% Changelog:
% 2013.06.07 - Creating in GPS1.8/gpsr_

state = gpsr_get;

% Check the fields
fields = {'study', 'subject', 'left', 'right', 'surface', 'perspective', 'atlas', 'sulci', 'shading'};
flag_changed = 0;

% study = sprintf('%s/parameters/%s/%s.mat', state.dir, studies();
for i_field = 1:length(fields)
    field = fields{i_field}
    if(~isfield(state, 'cortex'))
        state.cortex.study = 0;
    end
    
    value = state.cortex.(field);
    value_menu = get(state.menu.cortex.(field), 'Value');
    if(~isfield(state, field) || value ~= value_menu)
        state.cortex.(field) = value_menu;
        flag_changed = 1;
        
        switch field
            case 'study'
                flag_study_changed = 1;
            case 'subject'
                flag_subject_changed = 1;
        end
    end
end % for each field

% If the study changed, get a new list of subjects
if(flag_study_changed)
    study = get(state.menu.cortex.study, 'String');
    state.data.study = study{get(state.menu.cortex.study, 'Value')};
    study = gps_parameter(state, state.data.study);
    
    % Get the MRI directory
    if(~isempty(study_struct))
        state.data.mridir = study.mri.dir;
    else
        % Ask the user for the MRI directory if it wasn't pre-programmed
        state.data.mridir = uigetdir('', 'Study MRI Directory');
    end
    
    % Load the subjects
    state.data.subjects = dir(state.data.mridir);
    state.data.subjects(strcmp(state.data.subjects, '.') | strcmp(state.data.subjects, '..')) = [];
    state.cortex.subject = 1;
    set(state.menu.cortex.subject, 'Value', state.cortex.subject);
    flag_subject_changed = 1;
end


end % function