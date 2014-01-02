function study = gpse_convert_study(varargin)
% Converts a study into the GPS 1.7 framework or fills defaults
%
% Author: Alexander Conrad Nied (anied@cs.washington.edu)
%
% Input: The name for default study structure and optionally an old one to
% convert
% Output: Converted Study structure
%
% Changelog:
% 2012-09-18 Created based on GPS 1.6 data_defaultstudy.m, changed
% variables, removed some, removed GPS1.4 if clauses
% 2012-09-19 Modified to work under GPSe
% 2013-01-08 Added flag for PLV computation
% 2013-04-09 Updated to GPS1.8, changed the default sample rate
% 2013-04-25 Changed subset design to condition hierarchy
% 2013-07-10 Removed average_name and granger.singlesubject (moved to
% conditions)
% 2014-01-02 GPS1.9 Correctly reacts if the study did not exist before

past = 0;
if(nargin > 1 && ~isempty(varargin{1}))
    past = 1;
    name = varargin{1};
    oldstudy = varargin{2};
elseif(nargin == 1 && isstruct(varargin{1}))
    past = 1;
    oldstudy = varargin{1};
    name = oldstudy.name;
else
    name = varargin{1};
end

%% Basic Fields

% name
study.name = name;
study.study = name; % Yes redundant but useful

% type
study.type = 'study';

% last_edited
study.last_edited = 'new';

% version
study.version = 'GPS1.9';

% average_name removed

% basedir
if(past & isfield(oldstudy,'basedir') & ~isempty(oldstudy.basedir) & oldstudy.basedir ~= 0)
    study.basedir = oldstudy.basedir;
else
    answer = inputdlg({'Base Directory'}, 'What''s the study base directory', 1, {''});
    if(isempty(answer));
        error('Must specify a base directory');
    else
        study.basedir = answer{1};
    end
end

%% MRI

% rawdir
if(past & isfield(oldstudy,'mri') & isfield(oldstudy.mri,'rawdir') & ~isempty(oldstudy.mri.rawdir) & oldstudy.mri.rawdir ~= 0) %#ok<*AND2>
    study.mri.rawdir = oldstudy.mri.rawdir;
elseif(past & isfield(oldstudy,'surf') & isfield(oldstudy,'mri') & isfield(oldstudy.mri,'dir') & ~isempty(oldstudy.mri.dir) & oldstudy.mri.dir ~= 0)
    study.mri.rawdir = oldstudy.mri.dir;
else
    study.mri.rawdir = sprintf('%s/MRIraw', study.basedir);
end

% dir
if(past & ~isfield(oldstudy,'surf') & isfield(oldstudy,'mri') & isfield(oldstudy.mri,'dir') & ~isempty(oldstudy.mri.dir) & oldstudy.mri.dir ~= 0)
    study.mri.dir = oldstudy.mri.dir;
elseif(past & isfield(oldstudy,'surf') & isfield(oldstudy.surf,'dir') & ~isempty(oldstudy.surf.dir) & oldstudy.surf.dir ~= 0)
    study.mri.dir = oldstudy.surf.dir;
else
    study.mri.dir = sprintf('%s/MRI', study.basedir);
end

% smooth_level has been removed

%% meg

% dir
if(past & isfield(oldstudy,'meg') & isfield(oldstudy.meg,'dir') & ~isempty(oldstudy.meg.dir) & oldstudy.meg.dir ~= 0)
    study.meg.dir = oldstudy.meg.dir;
else
    study.meg.dir = sprintf('%s/MEG', study.basedir);
end

% raid_pi
if(past & isfield(oldstudy,'meg') & isfield(oldstudy.meg,'raid_pi') & ~isempty(oldstudy.meg.raid_pi))
    study.meg.raid_pi = oldstudy.meg.raid_pi;
else
    study.meg.raid_pi = 'gow';
end

% sample_rate
if(past & isfield(oldstudy,'meg') & isfield(oldstudy.meg,'sample_rate') & ~isempty(oldstudy.meg.sample_rate) & oldstudy.meg.sample_rate ~= 0)
    study.meg.sample_rate = oldstudy.meg.sample_rate;
else
    study.meg.sample_rate = 1200;
end

%% mne

% dir
if(past & isfield(oldstudy,'mne') & isfield(oldstudy.mne,'dir') & ~isempty(oldstudy.mne.dir) & oldstudy.mne.dir ~= 0)
    study.mne.dir = oldstudy.mne.dir;
else
    study.mne.dir = sprintf('%s/MNE', study.basedir);
%     study.mne.dir = sprintf('!%s/MEG/%%s/averages_covariances', study.basedir); % For subject interface
end

% start
if(past & isfield(oldstudy,'mne') & isfield(oldstudy.mne,'start') & ~isempty(oldstudy.mne.start))
    study.mne.start = oldstudy.mne.start;
else
    study.mne.start = -300;
end

% stop
if(past & isfield(oldstudy,'mne') & isfield(oldstudy.mne,'stop') & ~isempty(oldstudy.mne.stop))
    study.mne.stop = oldstudy.mne.stop;
else
    study.mne.stop = 1200;
end

% focusstart
if(past && isfield(oldstudy,'mne') && isfield(oldstudy.mne,'focusstart') && ~isempty(oldstudy.mne.focusstart))
    study.mne.focusstart = oldstudy.mne.focusstart;
else
    study.mne.focusstart = 100;
end

% focusstop
if(past && isfield(oldstudy,'mne') && isfield(oldstudy.mne,'focusstop') && ~isempty(oldstudy.mne.focusstop))
    study.mne.focusstop = oldstudy.mne.focusstop;
else
    study.mne.focusstop = 400;
end

% basestart
if(past & isfield(oldstudy,'mne') & isfield(oldstudy.mne,'basestart') & ~isempty(oldstudy.mne.basestart))
    study.mne.basestart = oldstudy.mne.basestart;
else
    study.mne.basestart = -100;
end

% basestop
if(past & isfield(oldstudy,'mne') & isfield(oldstudy.mne,'basestop') & ~isempty(oldstudy.mne.basestop))
    study.mne.basestop = oldstudy.mne.basestop;
else
    study.mne.basestop = 0;
end

% noisestart
if(past & isfield(oldstudy,'mne') & isfield(oldstudy.mne,'noisestart') & ~isempty(oldstudy.mne.noisestart))
    study.mne.noisestart = oldstudy.mne.noisestart;
else
    study.mne.noisestart = -300;
end

% noisestop
if(past & isfield(oldstudy,'mne') & isfield(oldstudy.mne,'noisestop') & ~isempty(oldstudy.mne.noisestop))
    study.mne.noisestop = oldstudy.mne.noisestop;
else
    study.mne.noisestop = 0;
end

% noisebasestart
if(past & isfield(oldstudy,'mne') & isfield(oldstudy.mne,'noisebasestart') & ~isempty(oldstudy.mne.noisebasestart))
    study.mne.noisebasestart = oldstudy.mne.noisebasestart;
else
    study.mne.noisebasestart = -300;
end

% noisebasestop
if(past & isfield(oldstudy,'mne') & isfield(oldstudy.mne,'noisebasestop') & ~isempty(oldstudy.mne.noisebasestop))
    study.mne.noisebasestop = oldstudy.mne.noisebasestop;
else
    study.mne.noisebasestop = 0;
end

% gradreject
if(past & isfield(oldstudy,'mne') & isfield(oldstudy.mne,'gradreject') & ~isempty(oldstudy.mne.gradreject))
    study.mne.gradreject = oldstudy.mne.gradreject;
else
    study.mne.gradreject = 300e-12;
end

% magreject
if(past & isfield(oldstudy,'mne') & isfield(oldstudy.mne,'magreject') & ~isempty(oldstudy.mne.magreject))
    study.mne.magreject = oldstudy.mne.magreject;
else
    study.mne.magreject = 100e-12;
end

% eogreject
if(past & isfield(oldstudy,'mne') & isfield(oldstudy.mne,'eogreject') & ~isempty(oldstudy.mne.eogreject))
    study.mne.eogreject = oldstudy.mne.eogreject;
else
    study.mne.eogreject = 0; % or 150e-6 if we are using it
end

% flag_depth
if(past & isfield(oldstudy,'mne') &  isfield(oldstudy.mne,'flag_depth') & ~isempty(oldstudy.mne.flag_depth))
    study.mne.flag_depth = oldstudy.mne.flag_depth;
else
    study.mne.flag_depth = false;
end

% flag_emptyroom
if(past & isfield(oldstudy,'mne') &  isfield(oldstudy.mne,'flag_emptyroom') & ~isempty(oldstudy.mne.flag_emptyroom))
    study.mne.flag_emptyroom = oldstudy.mne.flag_emptyroom;
else
    study.mne.flag_emptyroom = false;
end

% subj_done removed

%% Blocks & Subjects

% blocks
if(past & isfield(oldstudy,'blocks') & ~isempty(oldstudy.blocks))
    study.blocks = oldstudy.blocks;
else
    study.blocks = {'block1'};
end

% subjects
if(past & isfield(oldstudy,'subjects') & ~isempty(oldstudy.subjects))
    study.subjects = oldstudy.subjects;
else
    study.subjects = {sprintf('%s_01', study.name)};
end

%% Conditions

% conditions
if(past && isfield(oldstudy, 'conditions'));
    study.conditions = oldstudy.conditions;
elseif(past && isfield(oldstudy, 'subsets'));
    study.conditions = oldstudy.subsets;
else
    study.conditions = {'condition1'};
end

%% plv

% dir
if(past & isfield(oldstudy,'plv') & isfield(oldstudy.plv,'dir') & ~isempty(oldstudy.plv.dir) & oldstudy.plv.dir ~= 0)
    study.plv.dir = oldstudy.plv.dir;
elseif(past & isfield(oldstudy,'dir') & isfield(oldstudy.dir,'plv') & ~isempty(oldstudy.dir.plv) & oldstudy.dir.plv ~= 0)
    study.plv.dir = oldstudy.dir.plv;
else
    study.plv.dir = sprintf('%s/PLV', study.basedir);
end

% frequencies
if(past & isfield(oldstudy,'plv') & isfield(oldstudy.plv,'frequencies') & ~isempty(oldstudy.plv.frequencies))
    study.plv.frequencies = oldstudy.plv.frequencies;
else
    study.plv.frequencies = 40;
end

% flag
if(past & isfield(oldstudy,'plv') & isfield(oldstudy.plv,'flag') & ~isempty(oldstudy.plv.flag))
    study.plv.flag = oldstudy.plv.flag;
else
    study.plv.flag = false;
end

% start removed

% stop removed

% basestart removed

% basestop removed

%% granger

% dir
if(past & isfield(oldstudy,'granger') & isfield(oldstudy.granger,'dir') & ~isempty(oldstudy.granger.dir) & oldstudy.granger.dir ~= 0)
    study.granger.dir = oldstudy.granger.dir;
elseif(past & isfield(oldstudy,'dir') & isfield(oldstudy.dir,'granger') & ~isempty(oldstudy.dir.granger) & oldstudy.dir.granger ~= 0)
    study.granger.dir = oldstudy.dir.granger;
else
    study.granger.dir = sprintf('%s/Granger', study.basedir);
end

% start removed

% stop removed

% model_order
if(past & isfield(oldstudy,'granger') & isfield(oldstudy.granger,'model_order') & ~isempty(oldstudy.granger.model_order))
    study.granger.model_order = oldstudy.granger.model_order;
else
    study.granger.model_order = 5;
end

% W_gain
if(past & isfield(oldstudy,'granger') & isfield(oldstudy.granger,'W_gain') & ~isempty(oldstudy.granger.W_gain))
    study.granger.W_gain = oldstudy.granger.W_gain;
else
    study.granger.W_gain = 0.3;
end

% N_comp
if(past & isfield(oldstudy,'granger') & isfield(oldstudy.granger,'N_comp') & ~isempty(oldstudy.granger.N_comp))
    study.granger.N_comp = oldstudy.granger.N_comp;
else
    study.granger.N_comp = 2000;
end

% plv_freq
if(past & isfield(oldstudy,'granger') & isfield(oldstudy.granger,'plv_freq') & ~isempty(oldstudy.granger.plv_freq))
    study.granger.plv_freq = oldstudy.granger.plv_freq;
else
    study.granger.plv_freq = 40;
end

% srcs
if(past & isfield(oldstudy,'granger') & isfield(oldstudy.granger,'srcs') & ~isempty(oldstudy.granger.srcs))
    study.granger.srcs = oldstudy.granger.srcs;
else
    study.granger.srcs = {'L-STG'};
end

% snks
if(past & isfield(oldstudy,'granger') & isfield(oldstudy.granger,'snks') & ~isempty(oldstudy.granger.snks))
    study.granger.snks = oldstudy.granger.snks;
else
    study.granger.snks = {'L-SMG', 'L-AG', 'L-STG'};
end

% singlesubject removed

%% Update Last Edited
study.last_edited = datestr(now, 'yyyymmdd_HHMMSS');

end % function