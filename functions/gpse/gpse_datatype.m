function type = gpse_datatype(field)
% Gets the type of the field
%
% Author: Conrad Nied
%
% Input: field name (full, ie. 'study.mri.dir')
% Output: the type of this field
%
% Changelog:
% 2012.09.19 - Created based on GPS 1.6 data_type.m
% 2012.10.22 - Added a few missing values
% 2012.11.08 - Added subset.cortex.roiset and removed rois
% 2013.04.25 - GPS1.8 Changed subset design to condition hierarchy
% 2013.07.10 - Removed average_name and granger.singlesubject

%% Set up input

points = find([field '.'] == '.');
depth = length(points);

switch field(1 : points(1) - 1)
    case 'subject'
        if(depth == 1)
            type = 'struct';
        else
            switch field(points(1) + 1 : points(2) - 1)
                case {'name', 'study', 'type', 'version'}
                    type = 'string';
                case 'last_edited'
                    type = 'date';
                case 'active'
                    type = 'boolean';
                case {'blocks', 'conditions'}
                    type = 'cellstr';
                case 'mri'
                    if(depth == 2)
                        type = 'struct';
                    else
                        switch field(points(2) + 1 : points(3) - 1)
                            case {'dir', 'rawdir', 'sourcedir'}
                                type = 'directory';
                            case 'first_mpragefile'
                                type = 'filepath';
                            case 'corfile'
                                type = 'filepath';
                            case 'ico'
                                type = 'number';
                            otherwise
                                type = 'unknown';
                        end % switch field2
                    end % if there is more depth
                case 'meg'
                    if(depth == 2)
                        type = 'struct';
                    else
                        switch field(points(2) + 1 : points(3) - 1)
                            case {'raid'}
                                type = 'string';
                            case {'sample_rate'}
                                type = 'number';
                            case {'dir', 'sourcedir'}
                                type = 'directory';
                            case {'bad_eeg', 'bad_meg'}
                                type = 'array';
                            case 'projfile'
                                type = 'filepath';
                            case 'behav'
                                if(depth == 3)
                                    type = 'struct';
                                else
                                    switch field(points(3) + 1 : points(4) - 1)
                                        case 'trialdata'
                                            type = 'custom';
                                        case 'responses'
                                            type = 'matrix';
                                        case 'rts'
                                            type = 'array';
                                        case {'N_trials', 'N_missed'}
                                            type = 'number';
                                        otherwise
                                            type = 'unknown';
                                    end % switch field3
                                end % if there is more depth
                            otherwise
                                type = 'unknown';
                        end % switch field2
                    end % if there is more depth
                case 'mne'
                    if(depth == 2)
                        type = 'struct';
                    else
                        switch field(points(2) + 1 : points(3) - 1)
                            case 'dir'
                                type = 'directory';
                            case {'avefile', 'covfile', 'fwdfile', 'invfile'}
                                type = 'filepath';
                            case 'stcfilebase'
                                type = 'custom';
                            otherwise
                                type = 'unknown';
                        end % switch field2
                    end % if there is more depth
                case 'plv'
                    if(depth == 2)
                        type = 'struct';
                    else
                        switch field(points(2) + 1 : points(3) - 1)
                            case 'sample_rate'
                                type = 'number';
                            case 'sample_times'
                                type = 'number';
                            otherwise
                                type = 'unknown';
                        end % switch field2
                    end % if there is more depth
                otherwise
                    type = 'unknown';
            end % switch field1
        end % if there is more depth
    case 'study'
        if(depth == 1)
            type = 'struct';
        else
            switch field(points(1) + 1 : points(2) - 1)
                case {'name', 'type', 'study', 'version'}
                    type = 'string';
                case 'basedir'
                    type = 'directory';
                case 'last_edited'
                    type = 'date';
                case 'comments'
                    type = 'textbox';
                case {'blocks', 'subjects', 'conditions'}
                    type = 'cellstr';
                case 'mri'
                    if(depth == 2)
                        type = 'struct';
                    else
                        switch field(points(2) + 1 : points(3) - 1)
                            case {'rawdir', 'dir'}
                                type = 'directory';
                            otherwise
                                type = 'unknown';
                        end % switch field2
                    end % if there is more depth
                case 'meg'
                    if(depth == 2)
                        type = 'struct';
                    else
                        switch field(points(2) + 1 : points(3) - 1)
                            case 'sample_rate'
                                type = 'number';
                            case 'dir'
                                type = 'directory';
                            case 'raid_pi'
                                type = 'string';
                            otherwise
                                type = 'unknown';
                        end % switch field2
                    end % if there is more depth
                case 'mne'
                    if(depth == 2)
                        type = 'struct';
                    else
                        switch field(points(2) + 1 : points(3) - 1)
                            case 'dir'
                                type = 'directory';
                            case {'start', 'stop', 'focusstart',...
                                    'focusstop', 'basestart',...
                                    'basestop', 'noisestart',...
                                    'noisestop', 'noisebasestart',...
                                    'noisebasestop', 'magreject',...
                                    'gradreject', 'eogreject'}
                                type = 'number';
                            case {'flag_depth', 'flag_emptyroom'}
                                type = 'boolean';
                            otherwise
                                type = 'unknown';
                        end % switch field2
                    end % if there is more depth
                case 'plv'
                    if(depth == 2)
                        type = 'struct';
                    else
                        switch field(points(2) + 1 : points(3) - 1)
                            case 'dir'
                                type = 'directory';
                            case 'frequencies'
                                type = 'number';
                            case 'flag'
                                type = 'boolean';
                            otherwise
                                type = 'unknown';
                        end % switch field2
                    end % if there is more depth
                case 'granger'
                    if(depth == 2)
                        type = 'struct';
                    else
                        switch field(points(2) + 1 : points(3) - 1)
                            case 'dir'
                                type = 'directory';
                            case {'plv_freq', 'model_order', 'W_gain', 'N_comp'}
                                type = 'number';
                            case {'srcs', 'snks'}
                                type = 'cellstr';
                            otherwise
                                type = 'unknown';
                        end % switch field2
                    end % if there is more depth
                otherwise
                    type = 'unknown';
            end % switch field1
        end % if there is more depth
        
    case 'condition'
        if(depth == 1)
            type = 'struct';
        else
            switch field(points(1) + 1 : points(2) - 1)
                case {'name', 'type', 'study', 'version'}
                    type = 'string';
                case 'level'
                    type = 'number';
                case 'last_edited'
                    type = 'date';
                case 'subjects'
                    type = 'cellstr';
                case 'event'
                    if(depth == 2)
                        type = 'struct';
                    else
                        switch field(points(2) + 1 : points(3) - 1)
                            case {'code', 'basecode', 'start', 'stop', 'focusstart', 'focusstop', 'basestart', 'basestop'}
                                type = 'array';
                            case 'desc'
                                type = 'string';
                            otherwise
                                type = 'unknown';
                        end % switch field2
                    end % if there is more depth
                case 'cortex'
                    if(depth == 2)
                        type = 'struct';
                    else
                        switch field(points(2) + 1 : points(3) - 1)
                            case {'brain', 'roiset'}
                                type = 'string';
                            case {'plvrefdir'}
                                type = 'directory';
                            case {'actstc', 'plvstc'}
                                type = 'filepath';
                            otherwise
                                type = 'unknown';
                        end % switch field2
                    end % if there is more depth
                case 'granger'
                    if(depth == 2)
                        type = 'struct';
                    else
                        switch field(points(2) + 1 : points(3) - 1)
                            case {'input', 'output', 'significance'}
                                type = 'filepath';
                            case {'trialsperwave'}
                                type = 'number';
                            case {'focus'}
                                type = 'cellstr';
                            otherwise
                                type = 'unknown';
                        end % switch field2
                    end % if there is more depth
                otherwise
                    type = 'unknown';
            end % switch field1
        end % if there is more depth
        
    case 'settings' % So defunct
        if(depth == 1)
            type = 'struct';
        else
            switch field(points(1) + 1 : points(2) - 1)
                case 'savedir'
                    type = 'directory';
                case {'study', 'subject', 'condition', 'function'}
                    type = 'string';
                case 'last_edited'
                    type = 'date';
                case 'flags'
                    if(depth == 2)
                        type = 'struct';
                    else
                        switch field(points(2) + 1 : points(3) - 1)
                            case {'overwrite', 'applyconditions'}
                                type = 'number';
                            otherwise
                                type = 'unknown';
                        end % switch field2
                    end % if there is more depth
                otherwise
                    type = 'unknown';
            end % switch field1
        end % if there is more depth
        
    otherwise
        type = 'unknown';
end % switch field0

end % function