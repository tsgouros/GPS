function filename = gpsa_granger_filename(varargin)
% Gets the filename for granger analysis
%
% Author: Conrad Nied
%
% Changelog:
% 2012.12.05 - Created in GPS1.7 as gpsa_granger_filename
% 2013.01.14 - Added single subject clause
% 2013.04.25 - GPS1.8 Changed subset design to condition hierarchy

%% Get Fields

result = 0;

for i_argin = 1:length(varargin)
    parameter = varargin{i_argin};
    
    if(isstruct(parameter))
        state = parameter;
    else(ischar(parameter));
        if(strcmp(parameter, 'result'))
            result = 1;
        else
            result = 0;
        end
    end
end % for all variables

if(~exist('state', 'var'))
    state = gpsa_get;
end

%% Set Name
study = gpsa_parameter(state, state.study);
condition = gpsa_parameter(state, state.condition);

% Subject name (if single subject)
if(isfield(study.granger, 'singlesubject') && study.granger.singlesubject)
    subject = state.subject;
else
    subject = '';
end

% Subset?
if(isfield(state, 'subset') && ~isempty(state.subset))
    subset = state.subset;
    if(subset(1) ~= '_');
        subset = ['_' subset]; end
else
    subset = '';
end

% ROI set?
if(~strcmp(condition.name, condition.cortex.roiset))
    roiset = sprintf('_ROIs-%s', condition.cortex.roiset);
else
    roiset = '';
end

% Which Stream?
if(isfield(state, 'grangerstream') && strcmp(state.grangerstream, 'rs'))
    stream = '_Stream-rs';
elseif(isfield(state, 'grangerstream') && strcmp(state.grangerstream, 'seth'))
    stream = '_Stream-seth';
else % Regular
    stream = '';
end

description = sprintf('%s%s%s%s', subject, condition.name, subset, roiset);

if(result)
    filename = sprintf('%s/results/%s%s.mat', study.granger.dir, description, stream);
else
    filename = sprintf('%s/input/%s.mat', study.granger.dir, description);
end


end