function brain =  gps_brain_get(varargin)
% Retrieves the brain structure
%
% Author: Conrad Nied
%
% Changelog
% 2012.10.11 - Created
% 2013.06.21 - Improved functionality, it just needs the subject structure.
% 2013.06.28 - Processes brain2mat if it hasn't been done yet

if(nargin == 1)
    argin = varargin{1};
    if(isstruct(argin))
        if(strcmp(argin.name, 'state'))
            state = argin;
        else%if(strcmp(argin.type, 'subject'))
            subject = argin;
        end
    end
end

if(~exist('subject', 'var'))
    if(~exist('state', 'var'))
        state = gpsa_get;
    end
    subject = gpsa_parameter(state, state.subject);
end

brain_file = sprintf('%s/brain.mat', subject.mri.dir);

if(exist(brain_file, 'file'))
    brain = load(brain_file);
else
    if(~exist('state', 'var'))
        if(isfield(subject, 'study'))
            state.dir = gps_presets('dir');
            state.study = subject.study;
        else
            state = gpsa_get;
        end
        state.subject = subject.name;
    end
    gpsa_mri_brain2mat(state);
    
    if(exist(brain_file, 'file'))
        brain = load(brain_file);
    else
        fprintf('No brain found for %s\n', subject.name);
        brain = [];
    end
end

end % function