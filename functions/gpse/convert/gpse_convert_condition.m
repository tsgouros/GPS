function condition = gpse_convert_condition(condition)
% Prepares a default condition (or converts an old one to a new study)
%
% Author: A. Conrad Nied
%
% Input: condition name or old condition structure
% Output: condition structure
%
% Changelog:
% 2012.09.19 - Created based on GPS1.6 data_defaultcondition.m
% 2012.10.05 - Fixed error overwriting the cortex.actstc
% 2012.10.17 - Changed cortex.plvref to cortex.plvrefdir
% 2013.04.25 - GPS1.8 Changed subset design to condition hierarchy
% 2013.06.28 - Added granger.trialsperwave and granger.focus
% 2013.07.10 - Custom condition cortex brain is important now, added
% subjects

% Set up for handling refreshing an existing condition
if(isstruct(condition))
    name = condition.name;
    oldcondition = condition;
    condition = [];
    past = 1;
elseif(ischar(condition))
    name = condition;
    condition = [];
    past = 0;
else
    condition = [];
    return
end

% Get the environment
state = gpse_get('state');
study = gpse_parameter(state, state.study);

%% Basic Fields

% name
condition.name = name;

% study
condition.study = study.name;

% type
condition.type = 'condition';

% level - new in GPS1.8 for purifying the MNE inverse solution
if(past && isfield(oldcondition, 'level'))
    condition.level = oldcondition.level;
elseif(past && isfield(oldcondition, 'primary'))
    condition.level = 2 - oldcondition.primary;
else
    condition.level = 1;
end

% active removed

% last_edited
condition.last_edited = 'new';

% version
condition.version = 'GPS1.8';

% subjects
if(past && isfield(oldcondition, 'subjects'))
    condition.subjects = oldcondition.subjects;
else
    condition.subjects = study.subjects;
end

%% event

% desc - ription
if(past && isfield(oldcondition, 'event') && isfield(oldcondition.event, 'desc'))
    condition.event.desc = oldcondition.event.desc;
else
    condition.event.desc = condition.name;
end

% code
if(past && isfield(oldcondition, 'event') && isfield(oldcondition.event, 'code'))
    condition.event.code = oldcondition.event.code;
else
    condition.event.code = 200;
end

% basecode removed

% start
if(past && isfield(oldcondition, 'event') && isfield(oldcondition.event, 'start'))
    condition.event.start = oldcondition.event.start;
else
    condition.event.start = -300;
end

% stop
if(past && isfield(oldcondition, 'event') && isfield(oldcondition.event, 'stop'))
    condition.event.stop = oldcondition.event.stop;
else
    condition.event.stop = 1200;
end

% focusstart
if(past && isfield(oldcondition, 'event') && isfield(oldcondition.event, 'focusstart'))
    condition.event.focusstart = double(oldcondition.event.focusstart);
else
    condition.event.focusstart = double(100);
end

% focusstop
if(past && isfield(oldcondition, 'event') && isfield(oldcondition.event, 'focusstop'))
    condition.event.focusstop = double(oldcondition.event.focusstop);
else
    condition.event.focusstop = double(500);
end

% basestart
if(past && isfield(oldcondition, 'event') && isfield(oldcondition.event, 'basestart'))
    condition.event.basestart = oldcondition.event.basestart;
else
    condition.event.basestart = -100;
end

% tstop
if(past && isfield(oldcondition, 'event') && isfield(oldcondition.event, 'basestop'))
    condition.event.basestop = oldcondition.event.basestop;
else
    condition.event.basestop = 0;
end

%% Cortex

% brain
if(past && isfield(oldcondition, 'cortex') && isfield(oldcondition.cortex, 'brain'))
    condition.cortex.brain = oldcondition.cortex.brain;
else
    condition.cortex.brain = sprintf('%s_ave', study.name);
end

% plvrefdir
if(past && isfield(oldcondition, 'cortex') && isfield(oldcondition.cortex, 'plvrefdir') && ~isempty(oldcondition.cortex.plvrefdir))
    condition.cortex.plvrefdir = oldcondition.cortex.plvrefdir;
else
    condition.cortex.plvrefdir = sprintf('%s/rois/%s', study.plv.dir, condition.name);
end

% roiset
if(past && isfield(oldcondition, 'cortex') && isfield(oldcondition.cortex, 'roiset') && ~isempty(oldcondition.cortex.roiset))
    condition.cortex.roiset = oldcondition.cortex.roiset;
else
    condition.cortex.roiset = name;
end

%% Granger

% trialsperwave
if(past && isfield(oldcondition,'granger') && isfield(oldcondition.granger,'trialsperwave') && ~isempty(oldcondition.granger.trialsperwave))
    condition.granger.trialsperwave = oldcondition.granger.trialsperwave;
else
    condition.granger.trialsperwave = inf;
end

% focus
if(past && isfield(oldcondition,'granger') && isfield(oldcondition.granger,'focus') && ~isempty(oldcondition.granger.focus))
    condition.granger.focus = oldcondition.granger.focus;
else
    condition.granger.focus = {};
end

% % input
% if(past && isfield(oldcondition,'granger') && isfield(oldcondition.granger,'input') && ~isempty(oldcondition.granger.input))
%     condition.granger.input = oldcondition.granger.input;
% else
%     condition.granger.input = sprintf('%s/input/%s.mat', study.granger.dir, condition.name);
% end
% 
% % output
% if(past && isfield(oldcondition,'granger') && isfield(oldcondition.granger,'output') && ~isempty(oldcondition.granger.output))
%     condition.granger.output = oldcondition.granger.input;
% else
%     condition.granger.output = sprintf('%s/output/%s.mat', study.granger.dir, condition.name);
% end
% 
% % significance
% if(past && isfield(oldcondition,'granger') && isfield(oldcondition.granger,'signif') && ~isempty(oldcondition.granger.signif))
%     condition.granger.signif = oldcondition.granger.signif;
% else
%     condition.granger.signif = sprintf('%s/output/%s_significance.mat', study.granger.dir, condition.name);
% end

%% Update Last Edited
condition.last_edited = datestr(now, 'yyyymmdd_HHMMSS');

end % function