function value = gpse_defaults(field, varargin)
% Gets the default value of the field given the gpse_state
%
% Author: Conrad Nied
%
% Input: field name (full, ie. 'study.mri.dir') and optionally the state of
% the GPS system
% Output: the default value of this field
%
% Changelog:
% 2012.09.19 - Created
% 2012.10.23 - Changed to defaults to work with gpse_default button.

%% Set up input

% Get the status of the system if it isn't already provided
if(nargin == 2)
    state = varargin{1};
else
    state = gpse_get('state');
end

% Break up the field into constituents
points = find([field '.'] == '.');

% Value if the field isn't known
value = [];

switch field(1 : points(1) - 1)
    case 'subject'
        switch field(points(1) : end);
            case 'name'
                value = state.subject;
            case 'study'
                value = state.study;
            case 'type'
                value = 'subject';
            case 'active';
                value = 1;
            case 'last_edited';
                value = datestr(now, 'yyyymmdd_HHMMSS');
            case 'version'
                value = 'GPS1.7';
            case 'mri.dir';
                study = gpse_parameter(state, state.study);
                value = sprintf('%s/%s', study.mri.dir, state.subject);
            case 'mri.rawdir';
                study = gpse_parameter(state, state.study);
                value = sprintf('%s/%s', study.mri.rawdir, state.subject);
            case {'mri.sourcedir', 'meg.sourcedir'}
                value = '';
            case 'mri.first_mpragefile'
                subject = gpse_parameter(state, state.subject);
                value = sprintf('%s/', subject.mri.rawdir);
            case 'mri.corfile'
                subject = gpse_parameter(state, state.subject);
                value = sprintf('%s/mri/T1-neuromag/sets/COR.fif', subject.mri.dir);
            case 'meg.raid'
                value = 0;
            case 'meg.dir'
                study = gpse_parameter(state, state.study);
                value = sprintf('%s/%s', study.meg.dir, state.subject);
        end
        
        
        
%         if(depth == 1)
%             type = 'struct';
%         else
%             switch field(points(1) + 1 : points(2) - 1)
%                 case {'blocks', 'conditions'}
%                     type = 'cellstr';
%                 case 'meg'
%                     if(depth == 2)
%                         type = 'struct';
%                     else
%                         switch field(points(2) + 1 : points(3) - 1)
%                             case {'sample_rate'}
%                                 type = 'number';
%                             case {'bad_eeg', 'bad_meg'}
%                                 type = 'array';
%                             case 'projfile'
%                                 type = 'filepath';
%                             case 'behav'
%                                 if(depth == 3)
%                                     type = 'struct';
%                                 else
%                                     switch field(points(3) + 1 : points(4) - 1)
%                                         case 'trialdata'
%                                             type = 'custom';
%                                         case 'responses'
%                                             type = 'matrix';
%                                         case 'rts'
%                                             type = 'array';
%                                         case {'N_trials', 'N_missed'}
%                                             type = 'number';
%                                         otherwise
%                                             type = 'unknown';
%                                     end % switch field3
%                                 end % if there is more depth
%                             otherwise
%                                 type = 'unknown';
%                         end % switch field2
%                     end % if there is more depth
%                 case 'mne'
%                     if(depth == 2)
%                         type = 'struct';
%                     else
%                         switch field(points(2) + 1 : points(3) - 1)
%                             case 'dir'
%                                 type = 'directory';
%                             case {'avefile', 'covfile', 'fwdfile', 'invfile'}
%                                 type = 'filepath';
%                             case 'stcfilebase'
%                                 type = 'custom';
%                             otherwise
%                                 type = 'unknown';
%                         end % switch field2
%                     end % if there is more depth
%                 case 'plv'
%                     if(depth == 2)
%                         type = 'struct';
%                     else
%                         switch field(points(2) + 1 : points(3) - 1)
%                             case 'sample_rate'
%                                 type = 'number';
%                             case 'sample_times'
%                                 type = 'number';
%                             otherwise
%                                 type = 'unknown';
%                         end % switch field2
%                     end % if there is more depth
%                 otherwise
%                     type = 'unknown';
%             end % switch field1
%         end % if there is more depth
%     case 'study'
%         if(depth == 1)
%             type = 'struct';
%         else
%             switch field(points(1) + 1 : points(2) - 1)
%                 case {'name', 'average_name', 'type', 'study'}
%                     type = 'string';
%                 case 'basedir'
%                     type = 'directory';
%                 case 'last_edited'
%                     type = 'date';
%                 case 'comments'
%                     type = 'textbox';
%                 case {'blocks', 'subjects', 'subsets'}
%                     type = 'cellstr';
%                 case 'mri'
%                     if(depth == 2)
%                         type = 'struct';
%                     else
%                         switch field(points(2) + 1 : points(3) - 1)
%                             case {'rawdir', 'dir'}
%                                 type = 'directory';
%                             otherwise
%                                 type = 'unknown';
%                         end % switch field2
%                     end % if there is more depth
%                 case 'meg'
%                     if(depth == 2)
%                         type = 'struct';
%                     else
%                         switch field(points(2) + 1 : points(3) - 1)
%                             case 'sample_rate'
%                                 type = 'number';
%                             case 'dir'
%                                 type = 'directory';
%                             case 'raid_pi'
%                                 type = 'string';
%                             otherwise
%                                 type = 'unknown';
%                         end % switch field2
%                     end % if there is more depth
%                 case 'mne'
%                     if(depth == 2)
%                         type = 'struct';
%                     else
%                         switch field(points(2) + 1 : points(3) - 1)
%                             case 'dir'
%                                 type = 'directory';
%                             case {'start', 'stop', 'focusstart', 'focusstop', 'basestart', 'basestop', 'noisestart', 'noisestop', 'noisebasestart', 'noisebasestop'}
%                                 type = 'number';
%                             case {'flag_depth', 'flag_emptyroom'}
%                                 type = 'boolean';
%                             otherwise
%                                 type = 'unknown';
%                         end % switch field2
%                     end % if there is more depth
%                 case 'plv'
%                     if(depth == 2)
%                         type = 'struct';
%                     else
%                         switch field(points(2) + 1 : points(3) - 1)
%                             case 'dir'
%                                 type = 'directory';
%                             case 'frequencies'
%                                 type = 'number';
%                             otherwise
%                                 type = 'unknown';
%                         end % switch field2
%                     end % if there is more depth
%                 case 'granger'
%                     if(depth == 2)
%                         type = 'struct';
%                     else
%                         switch field(points(2) + 1 : points(3) - 1)
%                             case 'dir'
%                                 type = 'directory';
%                             case {'plv_freq', 'model_order', 'W_gain', 'N_comp'}
%                                 type = 'number';
%                             case {'srcs', 'snks'}
%                                 type = 'cellstr';
%                             case {'singlesubject'};
%                                 type = 'boolean';
%                             otherwise
%                                 type = 'unknown';
%                         end % switch field2
%                     end % if there is more depth
%                 otherwise
%                     type = 'unknown';
%             end % switch field1
%         end % if there is more depth
%         
%     case 'subset'
%         if(depth == 1)
%             type = 'struct';
%         else
%             switch field(points(1) + 1 : points(2) - 1)
%                 case {'name', 'type', 'study', 'version'}
%                     type = 'string';
%                 case {'primary', 'active'}
%                     type = 'boolean';
%                 case 'last_edited'
%                     type = 'date';
%                 case 'event'
%                     if(depth == 2)
%                         type = 'struct';
%                     else
%                         switch field(points(2) + 1 : points(3) - 1)
%                             case {'code', 'basecode', 'start', 'stop', 'focusstart', 'focusstop', 'basestart', 'basestop'}
%                                 type = 'array';
%                             case 'desc'
%                                 type = 'string';
%                             otherwise
%                                 type = 'unknown';
%                         end % switch field2
%                     end % if there is more depth
%                 case 'cortex'
%                     if(depth == 2)
%                         type = 'struct';
%                     else
%                         switch field(points(2) + 1 : points(3) - 1)
%                             case 'brain'
%                                 type = 'string';
%                             case 'roidir'
%                                 type = 'directory';
%                             case 'rois'
%                                 type = 'cellstr';
%                             case {'actstc', 'plvstc', 'plvref'}
%                                 type = 'filepath';
%                             otherwise
%                                 type = 'unknown';
%                         end % switch field2
%                     end % if there is more depth
%                 case 'granger'
%                     if(depth == 2)
%                         type = 'struct';
%                     else
%                         switch field(points(2) + 1 : points(3) - 1)
%                             case {'input', 'output', 'significance'}
%                                 type = 'filepath';
%                             otherwise
%                                 type = 'unknown';
%                         end % switch field2
%                     end % if there is more depth
%                 otherwise
%                     type = 'unknown';
%             end % switch field1
%         end % if there is more depth
end % switch field0

end % function