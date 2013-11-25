function gpsp_load_condition2
% Happens after you choose a comparison condition
%
% Author: A. Conrad Nied (conrad.logos@gmail.com)
%
% Changelog:
% 2013-07-15 Created from GPS1.8/gpsa_load_condition to ...2
% 2013-08-06 Fixed everything that should have a number 2 to it

state = gpsp_get;

%% Get the current condition
i_condition = get(state.data_condition2, 'Value');
conditions = get(state.data_condition2, 'String');
state.condition2 = conditions{i_condition};

study = gpsp_parameter(state, state.study);
condition = gpsp_parameter(state, state.condition2);

    
%% Set File Defaults
if(isempty(state.condition2) || isempty(condition))
    state.file_granger2 = study.granger.dir;
    state.file_activity2 = study.mne.dir;
    
else % Is a real condition
    
    % Set Default Data file
    state.file_granger2 = gps_filename(study, condition, 'granger_analysis_results');
    if(~exist(state.file_granger2, 'file'));
        other_file_granger2 = gps_filename(study, condition, 'granger_analysis_rawoutput');
        if(exist(other_file_granger2, 'file'))
            state.file_granger2 = other_file_granger2;
        else
            state.file_granger2 = study.granger.dir;
        end
    end
    
    % Set the default activation file
    state.file_activity2 = gps_filename(study, condition, 'mne_stc_avesubj_lh');
    if(~exist(state.file_activity2, 'file'))
        subject = gpsp_parameter(state, state.subject);
        if(~isempty(subject))
            filename = gps_filename(study, condition, subject, 'mne_stc_lh');
            if(exist(filename, 'file'))
                state.file_activity2 = filename;
            end
        end
    end
end % If real or not

%% Manage GUI

% Turn on the load button
set(state.data_granger2_load, 'String', 'Load');
set(state.data_granger2_load, 'FontWeight', 'Bold');
set(state.data_granger2_load, 'FontAngle', 'Normal');
set(state.data_act2_load, 'String', 'Load');
set(state.data_act2_load, 'FontWeight', 'Bold');
set(state.data_act2_load, 'FontAngle', 'Normal');

% Clear out old information
act2.name = 'act2';
granger2.name = 'granger2';
gpsp_set(act2);
gpsp_set(granger2);

%% Save and draw the brain

% Update handles structure
gpsp_set(state);
guidata(state.data_study, state);

end % function