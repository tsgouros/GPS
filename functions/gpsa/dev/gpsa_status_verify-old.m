function report = gpsa_status_verify(varargin)
% Checks the status of a process from the study's status matrix.
% 
% Author: A. Conrad Nied
% 
% Changelog:
% 2013.04.10 - Created in GPS1.8
% 2013.04.25 - Changed subset design to condition hierarchy

%% Process input

% Process input arguments
for i_argin = 1:nargin
    if(isstruct(varargin{i_argin}))
        state = varargin{i_argin};
    else
        checks = varargin{i_argin};
    end
end % for all input arguments

% Verify input arguments
if(~exist('state', 'var'))
    state = gpsa_get;
end
if(~exist('checks', 'var'))
    error('Not given a check')
end

% Verify input contents
if(~iscell(state.subject))
    state.subject = {state.subject};
end
if(~iscell(state.condition))
    state.condition = {state.condition};
end
if(~iscell(checks))
    checks = {checks};
end
N_checks = length(checks);

%% Determine the status

% Call the study's status matrix
study_status_filename = sprintf('%s/parameters/%s/status.mat', state.dir, state.study);

if(exist(study_status_filename, 'file'))
    study_status = load(study_status_filename);
else
    tempstate = state; tempstate.subject = state.subject{1}; tempstate.condition = state.condition{1};
    gpsa_status_investigate(tempstate, checks);
    for i_check = 1:N_checks
        check = checks{i_check};
        report.(check) = 0;
    end
    return;
end % If the file exists

% Go through the checks
for i_check = 1:N_checks
    check = checks{i_check};
    
    if(isfield(study_status, check))
        study_check = study_status.(check);
        
        status = 0;
        N_subjects = length(state.subject);
        N_conditions = length(state.condition);
        for i_subject = 1:N_subjects
            subject = state.subject{i_subject};
            
            if(isfield(study_check, subject))
                for i_condition = 1:N_conditions
                    condition = state.condition{i_condition};
                    
                    if(isfield(study_check.(subject), condition))
                        status = status + study_check.(subject).(condition);
                    else
                        tempstate = state; tempstate.subject = subject; tempstate.condition = condition;
                        gpsa_status_investigate(tempstate, check);
                    end % if the condition has information for this check
                end % for each condition
            else
                tempstate = state; tempstate.subject = subject; tempstate.condition = state.condition{1};
                gpsa_status_investigate(tempstate, check);
            end % if the subject has information for this check
        end % for each subject
        % (or assert it)?
        
        report.(check) = status / N_subjects / N_conditions;
        report.(check) = 0;
    else
        tempstate = state; tempstate.subject = state.subject{1}; tempstate.condition = state.condition{1};
        gpsa_status_investigate(tempstate, check);
        report.(check) = 0;
    end % If the check is instantiated
end

end % function