function GPSR_vars = rois_data_measure_load(hObject, GPSR_vars)
% Loads the measure data
%
% Author: Conrad Nied
%
% Input: The Granger Processing Stream ROIs handle
% Output: none, affects the GUI
%
% Date Created: 2012.06.16
% Last Modified: 2012.06.16
% 2012.10.09 - Superficially adapted to GPS1.7

% Get parameters
% study = gpsr_parameter(GPSR_vars, GPSR_vars.study);
% subject = gpsr_parameter(GPSR_vars, GPSR_vars.subject);
% condition = gpsr_parameter(GPSR_vars, GPSR_vars.condition);

type = get(hObject, 'tag');
underscores = strfind(type, '_');
type = type(underscores(1) + 1 : underscores(2) - 1);

switch type
    case {'mne', 'plv', 'custom'}
        files = getappdata(GPSR_vars.datafig, 'files');
        file = files.(type);
        
        if(strfind(file, '.stc') && exist(file, 'file'))
            % Left
            lact = mne_read_stc_file(file);

            % Right
            file = [file(1:(end-7)) '-rh.stc'];
            ract = mne_read_stc_file(file);
            
            if(isappdata(GPSR_vars.datafig, type))
                metric = getappdata(GPSR_vars.datafig, type);
            else
                metric.type = type;
                metric.num = 1 + strcmp(type, 'plv')...
                    + 2 * strcmp(type, 'custom');
            end

            % Add data to measures
            metric.data.raw = [lact.data; ract.data];
            metric.data.tmin = lact.tmin;
            metric.data.tstep = lact.tstep;
            setappdata(GPSR_vars.datafig, metric.type, metric);
            
            % Add to brain vertex constraints
            if(strcmp(type, 'mne'))
                brain = getappdata(GPSR_vars.datafig, 'brain');
                brain.decIndices = [lact.vertices + 1; ract.vertices + brain.N_L + 1];
                brain.decN_L = length(lact.data);
                brain.decN_R = length(ract.data);
                brain.decN = brain.decN_L + brain.decN_R;
                setappdata(GPSR_vars.datafig, 'brain', brain);
            end
            
            % Set current metric to this one
            set(GPSR_vars.metrics_list, 'Value', metric.num);
            
            % Turn off the load button
            button = sprintf('data_%s_load', type);
            set(GPSR_vars.(button), 'Enable', 'off');
            set(GPSR_vars.(button), 'String', 'Done');
            
            % Enable this measure in other parts of the GUI
            button = sprintf('quick_%s', type);
            set(GPSR_vars.(button), 'Enable', 'on');
%             
%             button = sprintf('brain_%s_on', type);
%             set(GPSR_vars.(button), 'Enable', 'on');
            
            % Update the GUI
            guidata(GPSR_vars.data_subject_list, GPSR_vars);
            
            % Start the metric design
            GPSR_vars = rois_metrics_settings_load(GPSR_vars);
            button = sprintf('quick_%s', type);
            GPSR_vars = guidata(GPSR_vars.(button));
            rois_metrics_compute(GPSR_vars.(button), GPSR_vars);
        elseif(~isempty(strfind(file, '.mat')) && exist(file, 'file'))
            matcontents = load(file);
            
            if(isappdata(GPSR_vars.datafig, type))
                metric = getappdata(GPSR_vars.datafig, type);
            else
                metric.type = type;
                metric.num = 1 + strcmp(type, 'plv')...
                    + 2 * strcmp(type, 'custom');
            end
            
            % Add data that is available
            if(isfield(matcontents, 'data'));
                metric.data.raw = matcontents.data;
            elseif(isfield(matcontents, 'phase_locking'));
                metric.data.raw = matcontents.phase_locking;
            end
            
            if(isfield(matcontents, 'tmin'));
                metric.data.tmin = matcontents.tmin;
            elseif(isfield(matcontents, 'sample_times'));
                metric.data.tmin = matcontents.sample_times(1);
            end
            
            if(isfield(matcontents, 'tstep'));
                metric.data.tstep = matcontents.tstep;
            elseif(isfield(matcontents, 'sample_times'));
                metric.data.tstep = matcontents.sample_times(2) - matcontents.sample_times(1);
            end

            setappdata(GPSR_vars.datafig, metric.type, metric);
            
            % Unable to add to brain vertex constraints
            
            % Set current metric to this one
            set(GPSR_vars.metrics_list, 'Value', metric.num);
            
            % Turn off the load button
            button = sprintf('data_%s_load', type);
            set(GPSR_vars.(button), 'Enable', 'off');
            set(GPSR_vars.(button), 'String', 'Done');
            
            % Enable this measure in other parts of the GUI
            button = sprintf('quick_%s', type);
            set(GPSR_vars.(button), 'Enable', 'on');
%             
%             button = sprintf('brain_%s_on', type);
%             set(GPSR_vars.(button), 'Enable', 'on');
            
            % Update the GUI
            guidata(GPSR_vars.data_subject_list, GPSR_vars);
            
            % Start the metric design
            GPSR_vars = rois_metrics_settings_load(GPSR_vars);
            button = sprintf('quick_%s', type);
            GPSR_vars = guidata(GPSR_vars.(button));
            rois_metrics_compute(GPSR_vars.(button), GPSR_vars);
        else
            warning = sprintf('You do not have a STC or MAT file listed for the %s measure\n%s',...
                type, file);
            warndlg(warning);
        end
    case 'oldregions'
        warning = sprintf('Not ready for this function yet');
        warndlg(warning);
end

end % function
