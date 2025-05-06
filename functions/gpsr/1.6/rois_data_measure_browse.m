function GPSR_vars = rois_data_measure_browse(GPSR_vars, type)
% Browses for the measure data file
%
% Author: Conrad Nied
%
% Input: The Granger Processing Stream ROIs handle
% Output: none, affects the GUI
%
% Date Created: 2012.06.16
% Last Modified: 2012.06.16

switch type
    case {'mne', 'plv', 'custom'}
        files = getappdata(GPSR_vars.datafig, 'files');
        
        file = files.(type);
        titlestr = sprintf('Select the Left %s STC File',...
            type);
        [filename, path] = uigetfile(file, titlestr);
        newfile = [path filename];

        if(~isnumeric(filename) && ~strcmp(file, newfile))
            % Set Data file
            files.(type) = newfile;

            % Turn on the load button
            button = sprintf('data_%s_load', type);
            set(GPSR_vars.(button), 'Enable', 'on');
            set(GPSR_vars.(button), 'String', 'Load');
            
            % Update the files repository and GUI
            setappdata(GPSR_vars.datafig, 'files', files);
            guidata(GPSR_vars.data_subject_list, GPSR_vars);
        end
    case 'oldregions'
        files = getappdata(GPSR_vars.datafig, 'files');
        
        file = files.oldroidir;
        titlestr = sprintf('Select the old ROIs directory');
        newfile = uigetdir(file, titlestr);

        if(~isnumeric(newfile) && ~strcmp(file, newfile))
            % Set Data file
            files.oldroidir = newfile;

            % Turn on the load button
            button = sprintf('data_%s_load', type);
            set(GPSR_vars.(button), 'Enable', 'on');
            set(GPSR_vars.(button), 'String', 'Load');
            
            % Update the files repository and GUI
            setappdata(GPSR_vars.datafig, 'files', files);
            guidata(GPSR_vars.data_subject_list, GPSR_vars);
        end
end

end % function
