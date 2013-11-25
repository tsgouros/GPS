function gpsa_do(varargin)
% Performs functions as specified by the GPSa GUI
%
% Author: A. Conrad Nied
%
% Changelog:
% 2012.10.02 - GPS1.7/gpsa_do.m created. loosely based on GPS1.6/do.m
% 2012.10.30 - If state.subsets or .subjects is empty, it does all
% 2013.04.25 - GPS1.8 Adapted subset design to condition hierarchy

%% Inputs

if(nargin == 2)
    state = varargin{1};
    functions = varargin{2};
elseif (nargin == 1)
    state = gpsa_get;
    functions = varargin{1};
else
%     state = gpsa_get;
%     functions = state.function;
%     be sad
    return
end

%% Get the functions we are processing

% Make sure it is in a cell array
if(ischar(functions))
    functions = {functions};
end

% Get batch selection if the function is batch
if(isfield(state, 'gui') && ~isempty(strfind(functions{1}, 'batch')))
    i_new_functions = [];
    
    % For each button in the series (stages or functions)
    for i_search = 1:10
        
        % Get the button name
        if(strcmp(functions{1}, 'gpsa_batch'))
            checkbox = sprintf('s%d_check', i_search);
            button = sprintf('s%d_button', i_search);
        else
            checkbox = sprintf('f%d_check', i_search);
            button = sprintf('f%d_button', i_search);
        end
        
        % Break if finished, or continue adding selected functions
        if(strcmp(functions{1}, get(state.gui.(button), 'Tag')))
            break;
        elseif(isfield(state.gui, checkbox) && get(state.gui.(checkbox), 'Value'))
            i_new_functions = [i_new_functions i_search]; %#ok<AGROW>
        end % If the button doesn't have it selected for batch
    end % Search through all functions
    
end % If the GUI is open

% Expand functions that are supersets or batch also look for custom study
% functions
i_function = 1;
while(i_function <= length(functions))
    
    % Custom study functions
    if(exist([functions{i_function} '_' state.study], 'file'))
        functions{i_function} = [functions{i_function} '_' state.study];
    end % if the study custom function exists
    
    % Switch between function names
    switch functions{i_function}
        case {'gpsa_meg', 'gpsa_meg_batch'}
            new_functions = gpsa_meg_functions;
            for i = 1:length(new_functions); new_functions{i} = ['gpsa_meg_' new_functions{i}]; end
            
            if(exist('i_new_functions', 'var')); new_functions = new_functions(i_new_functions); end
            
            functions = cat(2, functions{1:i_function - 1}, new_functions, functions{i_function + 1:end});
            
        case {'gpsa_mri', 'gpsa_mri_batch'}
            new_functions = gpsa_mri_functions;
            for i = 1:length(new_functions); new_functions{i} = ['gpsa_mri_' new_functions{i}]; end
            
            if(exist('i_new_functions', 'var')); new_functions = new_functions(i_new_functions); end
            
            functions = cat(2, functions{1:i_function - 1}, new_functions, functions{i_function + 1:end});
            
        case {'gpsa_mne', 'gpsa_mne_batch'}
            new_functions = gpsa_mne_functions;
            for i = 1:length(new_functions); new_functions{i} = ['gpsa_mne_' new_functions{i}]; end
            
            if(exist('i_new_functions', 'var')); new_functions = new_functions(i_new_functions); end
            
            functions = cat(2, functions{1:i_function - 1}, new_functions, functions{i_function + 1:end});
            
        case {'gpsa_plv', 'gpsa_plv_batch'}
            new_functions = gpsa_plv_functions;
            for i = 1:length(new_functions); new_functions{i} = ['gpsa_plv_' new_functions{i}]; end
            
            if(exist('i_new_functions', 'var')); new_functions = new_functions(i_new_functions); end
            
            functions = cat(2, functions{1:i_function - 1}, new_functions, functions{i_function + 1:end});
            
        case {'gpsa_granger', 'gpsa_granger_batch'}
            new_functions = gpsa_granger_functions;
            for i = 1:length(new_functions); new_functions{i} = ['gpsa_granger_' new_functions{i}]; end
            
            if(exist('i_new_functions', 'var')); new_functions = new_functions(i_new_functions); end
            
            functions = cat(2, functions{1:i_function - 1}, new_functions, functions{i_function + 1:end});
            
        case {'gpsa_batch'}
            new_functions = {'meg', 'mri', 'mne', 'plv', 'granger'}; % no util
            for i = 1:length(new_functions); new_functions{i} = ['gpsa_' new_functions{i}]; end
            
            if(exist('i_new_functions', 'var')); new_functions = new_functions(i_new_functions - 1); end
            clear i_new_functions;
            
            functions = cat(2, functions{1:i_function - 1}, new_functions, functions{i_function + 1:end});
        otherwise
            i_function = i_function + 1;
    end % switch on the function name
end % iterate through function calls, expanding if necessary

%% Get the subjects and conditions

% Subjects
if(isfield(state, 'gui'))
    subjects = get(state.gui.subject_list, 'String');
    i_subjects = get(state.gui.subject_list, 'Value');
    subjects = subjects(i_subjects);
else
    subjects = state.subject;
    if(isempty(subjects)) % Do all if blank
        subjects = study.subjects;
    elseif(ischar(subjects))
        subjects = {subjects};
    end
end

% Conditions
if(isfield(state, 'gui'))
    conditions = get(state.gui.condition_list, 'String');
    i_conditions = get(state.gui.condition_list, 'Value');
    conditions = conditions(i_conditions);
    for i_condition = 1:length(conditions)
        conditions{i_condition} = str_unbold(conditions{i_condition});
    end
else
    conditions = state.condition;
    if(isempty(conditions)) % Do all if blank
        conditions = study.conditions;
    elseif(ischar(conditions))
        conditions = {conditions};
    end
end

% Set override if it is not already set
if(~isfield(state, 'override'))
    state.override = 0;
end

%% Do functions

for i_function = 1:length(functions)
    state.function = functions{i_function};
    
    report = eval([state.function '(state, ''t'')']);
    N_subjects = length(subjects) * report.spec_subj + (1 - report.spec_subj);
    N_conditions = length(conditions) * (report.spec_cond>0) + (1 - (report.spec_cond>0));
    
    for i_subject = 1:N_subjects
        state.subject = subjects{i_subject};
        
        for i_condition = 1:N_conditions
            state.condition = conditions{i_condition};
            fprintf('%s %s %s\n', state.function(6:end), state.subject, state.condition);
            
            try
                % Do we do this function?
                progress = eval([state.function '(state, ''p'')']);
                
%                 tbegin = tic;
                
%                 if((progress.ready || state.override) && (~progress.finished || state.override || ~isempty(strfind(state.function, 'util'))));
                if(progress.ready && (~progress.finished || state.override || ~isempty(strfind(state.function, 'util'))));
                    fprintf('\tComputing\n');
                    eval([state.function '(state, ''c'')']);
                end
                
%                 gpsa_log(state, toc(tbegin));
            catch error_msg
                rethrow(error_msg)
                % Format message to user
                message = {'There has been an error in the program',...
                    ' ', state.function, state.subject, state.condition,...
                    ' ', error_msg.message, ' ', 'Stack:'};
                
                % Add stack
                for i_prog = 1:length(error_msg.stack);
                    message{end + 1} = sprintf('%s (line %d)',...
                        error_msg.stack(i_prog).name, ...
                        error_msg.stack(i_prog).line);
                end
                
                % If there is java
                [~, hostname] = unix('hostname');
                
                if(sum(strcmp({'launchp'}, hostname(1:7))))
                    throw(error_msg);
                else
                    % Tell the user of the error
                    gps_email_user(message);
                end
                
                fprintf('\n\nEnded with errors (check email)\n\n');
                
                % Put Matlab in keyboard mode so the error can be diagnosed
%                 keyboard
                return
            end % Try/Catch Errors
        end % for each condition
    end % for each subject
end % for each function

%% Redraw colors on the GUI
if(isfield(state, 'gui'))
    gpsa_color_compute;
end

fprintf('Done\n');

end % function gpsa_do.m