function gpsa_init_studies
% Initializes figure components for GPS: Analysis
%
% Author: Alexander Conrad Nied (anied@cs.washington.edu)
%
% Changelog:
% 2012-09-17 Created
% 2012-09-18 Initializes subject list and gets the study parameter.
% 2012-10-22 Draws from gps_preset now
% 2013-04-05 Updated to GPS 1.8, loads user specific studies now
% 2013-04-25 Renamed subsubset subset
% 2013-06-18 Changed USERNAME to USER environmental lookup
% 2014-01-02 GPS1.9 Asks for a first study if there are none listed

state = gpsa_get('state');

%% Load study list

% Get the list of folders from the parameters folder
files = dir(gps_presets('parameters'));

% Presume each name of a folder is a different study (should be)
state.studies = {files.name};

% Remove non-study entries
for i_study = length(state.studies):-1:1
    if(state.studies{i_study}(1) == '.' || strcmp(state.studies{i_study}, 'GPS'))
        state.studies(i_study) = [];
    end
end

% Try to load the list of studies specified for this user
user = getenv('USER');
userstudies_filename = sprintf('%s/GPS/userstudies.mat', gps_presets('parameters'));

if(exist(userstudies_filename, 'file'))
    userstudies = load(userstudies_filename);
    
    if(isfield(userstudies, user))
        userstudies = intersect(userstudies.(user), state.studies);
        if(~isempty(userstudies))
            state.studies = userstudies;
        end
    end
end % If the preset file exists

% If there are no studies, ask the user to make one
if(isempty(state.studies))
    state.studies = inputdlg('Name your first study to add to GPS', 'No studies detected');
end

% Set the list of studies to this list
set(state.gui.study_list, 'String', state.studies);

% Add a blank subsubset
if(~isfield(state, 'subset'))
    state.subset = '';
end

% Save this set to the GUI state
gpsa_set(state);

% Load the study
gpsa_load_study;


end % function