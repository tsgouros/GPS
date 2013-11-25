function gpsa_load_subject
% Loads subject information for GPS: Analysis
%
% Author: A. Conrad Nied
%
% Changelog:
% 2012.09.19 - created, branched from gpsa_init_studies
% 2013.06.11 - Updated for GPS1.8, changed variable names

state = gpsa_get;

% Set the index of the list if it exceeds the bounds
i_subject = get(state.gui.subject_list, 'Value');
if(max(i_subject) > length(state.subjects) || min(i_subject) < 1)
    i_subject = 1;
    set(state.gui.subject_list, 'Value', i_subject);
end % If i_subject is invalid

% Get the subject parameter
for j_subject = i_subject
    state.subject = state.subjects{j_subject};
    subject = gpsa_parameter(state.subject);
    
    % Initialize a subject if the structure didn't exist
    if(isempty(subject))
        subject.name = state.subject;
    end

    % Check the fields of the subject structure
    subject = gpse_convert_subject(subject);
    gpsa_parameter(subject);
end

% Save State
gpsa_set(state);

end % function