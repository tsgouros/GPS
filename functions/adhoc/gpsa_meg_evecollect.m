function gpsa_meg_evecollect(varargin)
% Collects the behaviorals for each subject and writes it into a csv file
% 
% Author: A. Conrad Nied (conrad.logos@gmail.com)
%
% Changelog:
% 2013.06.26 - Created based on GPS1.8/gpsa_meg_eveproc

[state, ~] = gpsa_inputs(varargin);

study = gpsa_parameter(state, state.study);

% Load and concatenate subjects
for i_subject = 1:length(study.subjects)
    asubject = gpsa_parameter(state, study.subjects{i_subject});
    
    atrialdata = asubject.meg.behav.trialdata;
    for i_trial = 1:length(atrialdata)
        atrialdata(i_trial).subject = study.subjects{i_subject};
    end
    
    if(i_subject == 1)
        trialdata = atrialdata;
    else
        trialdata = [trialdata atrialdata]; %#ok<AGROW>
    end
end % For each subject

filename = sprintf('%s/%s/%s_behaviorals.csv', gps_presets('parameters'), study.name, study.name);

struct2csv(trialdata, filename);

end