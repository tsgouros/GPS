function gpsa_color_compute()
% Computes the colors for entries in for GPS: Analysis
%
% Author: Alexander Conrad Nied (anied@cs.washington.edu)
%
% Changelog:
% 2012-09-21 Created
% 2012-09-27 Disabled because it doesn't work with the button version yet
% 2012-10-03 Re-enabled and remade to confirm to current functional
% layout
% 2012-11-07 Doesn't find status if autocolor is off, just says 0
% 2013-04-25 GPS1.8 Changed subset design to condition hierarchy
% 2013-07-10 Added applicability
% 2014-01-06 GPS1.9 Works with a variable number of stages

orig_state = gpsa_get;
state = orig_state;

%% Compute functional completion for each function

status = [];

% Gather groups
stages = gps_presets('stages');
subjects = get(state.gui.subject_list, 'String');
i_subjects = get(state.gui.subject_list, 'Value');
subjects = subjects(i_subjects);
conditions = get(state.gui.condition_list, 'String');
i_conditions = get(state.gui.condition_list, 'Value');
conditions = conditions(i_conditions);

% Iterate for each instance of the functions
for i_stage = 1:length(stages)
    stage = stages{i_stage};
    
    functions = eval(['gpsa_' stage '_functions']);
    for i_function = 1:length(functions);
        state.function = functions{i_function};
        tag = sprintf('gpsa_%s_%s', stage, state.function);
        study_tag = sprintf('%s_%s', tag, state.study);
        
%         tic
        % If we are coloring
        if(state.autocolor && exist(tag, 'file'))
            
%             if(exist(tag, 'file'))
                type = eval([tag '(''t'')']);
%             else
%                 type.spec_subj = 0;
%                 type.spec_cond = 0;
%             end
            
            % Allocate
            N_subjects = length(subjects) ^ (type.spec_subj > 0);
            N_conditions = length(conditions) ^ (type.spec_cond > 0);
            ready = 0;
            progress = 0;
            finished = 0;
            applicable = 0;
            
            for i_subject = 1:N_subjects
                state.subject = subjects{i_subject};
                
                for i_condition = 1:N_conditions
                    state.condition = str_unbold(conditions{i_condition});
                    
                    if(exist(study_tag, 'file'))
                        report = eval([study_tag '(state, ''p'')']);
                    elseif(exist(tag, 'file'))
                        report = eval([tag '(state, ''p'')']);
                    else
                        report.ready = 0;
                        report.progress = 0;
                        report.finished = 0;
                        report.applicable = 0;
                    end
                    
                    ready = ready + report.ready;
                    progress = progress + report.progress;
                    finished = finished + report.finished;
                    if(isfield(report, 'applicable'))
                        applicable = applicable + report.applicable;
                    else % Default is yet, it is
                        applicable = applicable + 1;
                    end
                    
%                     if(report.progress ~= 1)
%                         fprintf('%10s %25s %20s p=%d\n', state.subject, state.condition, tag, report.progress);
%                     end
                end
            end % for each subject
        else % Grey out everything
            ready = 0;
            progress = 0;
            finished = 0;
            applicable = 0;
            N_subjects = 1;
            N_conditions = 1;
        end
        
        status.(stage).(state.function).tag = tag;
        status.(stage).(state.function).ready = ready;
        status.(stage).(state.function).progress = progress;
        status.(stage).(state.function).finished = finished;
        status.(stage).(state.function).applicable = applicable;
        status.(stage).(state.function).N = N_subjects * N_conditions;
%         fprintf('%30s %3.3f\n', state.function, toc); 
    end % for each function
%     fprintf('\n');
end % for each stage

%% Save the state and draw the functional completion

state = orig_state;
state.gui.status = status;
gpsa_set(state);

gpsa_color_draw;

end % function