function subject = gpse_convert_subject(subject, varargin)
% Prepares a default subject (or converts an old one to a new study)
%
% Author: A. Conrad Nied
%
% Input: Subject name or existing structure
% Output: Subject structure
%
% Changelog:
% 2012.09.19 - Created based on GPS1.6 data_defaultsubject.m
% 2012.10.11 - Removed CPLEX exception
% 2013.01.08 - GPS1.7 Added ICO
% 2013.01.11 - Enabled submitting a state with it
% 2013.04.30 - Adopted GPS1.8 conventions. Removed some useless variables
% and added

if(isstruct(subject))
    name = subject.name;
    oldsubject = subject;
    subject = [];
    past = 1;
elseif(ischar(subject))
    name = subject;
    subject = [];
    past = 0;
else
    keyboard
    subject = [];
    return
end

% Get the environment
if(nargin == 2)
    state = varargin{1};
else
    state = gpse_get('state');
end
study = gpse_parameter(state.study);

%% Basic Fields

% name
subject.name = name;

% study
subject.study = study.name;

% type
subject.type = 'subject';

% last_edited
subject.last_edited = '';

% version -- this should really be pulled from a central location.
subject.version = 'GPS2.0';

%% MRI Fields

% rawdir
if(past & isfield(oldsubject,'mri') & isfield(oldsubject.mri,'rawdir') & ~isempty(oldsubject.mri.rawdir))
    subject.mri.rawdir = oldsubject.mri.rawdir;
elseif(past & isfield(oldsubject,'mri') & isfield(oldsubject.mri,'dir') & ~isfield(oldsubject.mri,'rawdir') & ~isempty(oldsubject.mri.dir) & oldsubject.mri.dir ~= 0)
    subject.mri.rawdir = oldsubject.mri.dir;
else
    subject.mri.rawdir = sprintf('%s/%s', study.mri.rawdir, subject.name);
end

% sourcedir
if(past & isfield(oldsubject,'mri') & isfield(oldsubject.mri,'sourcedir') & ~isempty(oldsubject.mri.sourcedir))
    subject.mri.sourcedir = oldsubject.mri.sourcedir;
else
    subject.mri.sourcedir = '';
end

% first_mpragefile
if(past & isfield(oldsubject,'mri') & isfield(oldsubject.mri,'first_mpragefile') & ~isempty(oldsubject.mri.first_mpragefile))
    subject.mri.first_mpragefile = oldsubject.mri.first_mpragefile;
else
    subject.mri.first_mpragefile = '';
end

% For the first_mpragefile complete the filename if not already completed
dashes = strfind(subject.mri.first_mpragefile, '/');
if(isempty(dashes))
    subject.mri.first_mpragefile = sprintf('%s/%s', subject.mri.rawdir, subject.mri.first_mpragefile);
end

% dir
if(past & isfield(oldsubject,'mri') & isfield(oldsubject.mri,'dir') & ~isempty(oldsubject.mri.dir) & oldsubject.mri.dir ~= 0 & ~isfield(oldsubject,'surf'))
    subject.mri.dir = oldsubject.mri.dir;
elseif(past & isfield(oldsubject,'surf') & isfield(oldsubject.surf,'dir') & ~isempty(oldsubject.surf.dir) & oldsubject.surf.dir ~= 0)
    subject.mri.dir = oldsubject.surf.dir;
else
    subject.mri.dir = sprintf('%s/%s', study.mri.dir, subject.name);
end

% corfile
if(past & isfield(oldsubject,'mri') & isfield(oldsubject.mri,'corfile') & ~isempty(oldsubject.mri.corfile))
    subject.mri.corfile = oldsubject.mri.corfile;
elseif(past & isfield(oldsubject,'surf') & isfield(oldsubject.surf,'corfile') & ~isempty(oldsubject.surf.corfile))
    subject.mri.corfile = oldsubject.surf.corfile;
else
    subject.mri.corfile = 'COR.fif';
end

% For the corfile complete the filename if not already completed
dashes = strfind(subject.mri.corfile, '/');
if(isempty(dashes))
    subject.mri.corfile = sprintf('%s/mri/T1-neuromag/sets/%s', subject.mri.dir, subject.mri.corfile);
end

% ico
if(past & isfield(oldsubject,'mri') & isfield(oldsubject.mri,'ico') & ~isempty(oldsubject.mri.ico))
    subject.mri.ico = oldsubject.mri.ico;
else
    subject.mri.ico = 7;
end

%% MEG Fields

% raid
if(past & isfield(oldsubject,'meg') & isfield(oldsubject.meg,'raid') & ~isempty(oldsubject.meg.raid)) %#ok<*AND2>
    if(isnumeric(oldsubject.meg.raid))
        oldsubject.meg.raid = num2str(oldsubject.meg.raid);
    end
    subject.meg.raid = oldsubject.meg.raid;
else
    subject.meg.raid = 'research';
end

% dir
if(past & isfield(oldsubject,'meg') & isfield(oldsubject.meg,'dir') & ~isempty(oldsubject.meg.dir) & oldsubject.meg.dir ~= 0)
    subject.meg.dir = oldsubject.meg.dir;
else
    subject.meg.dir = sprintf('%s/%s', study.meg.dir, subject.name);
end

% sourcedir
if(past & isfield(oldsubject,'meg') & isfield(oldsubject.meg,'sourcedir') & ~isempty(oldsubject.meg.sourcedir))
    subject.meg.sourcedir = oldsubject.meg.sourcedir;
else
    subject.meg.sourcedir = '';
end

% bad_eeg
if(past & isfield(oldsubject,'meg') & isfield(oldsubject.meg,'bad_eeg') & ~isempty(oldsubject.meg.bad_eeg))
    subject.meg.bad_eeg = oldsubject.meg.bad_eeg;
else
    subject.meg.bad_eeg = [];
end

% bad_meg
if(past & isfield(oldsubject,'meg') & isfield(oldsubject.meg,'bad_meg') & ~isempty(oldsubject.meg.bad_meg))
    subject.meg.bad_meg = oldsubject.meg.bad_meg;
else
    subject.meg.bad_meg = [];
end

% sample_rate
if(past & isfield(oldsubject,'sample_rate') & isfield(oldsubject.meg,'sample_rate') & ~isempty(oldsubject.meg.sample_rate))
    subject.meg.sample_rate = oldsubject.meg.sample_rate;
else
    subject.meg.sample_rate = 0;
end

% blocks
if(past & isfield(oldsubject,'blocks') & ~isempty(oldsubject.blocks))
    if(sum(strcmp(oldsubject.blocks,'none')) == 1)
        subject.conditions = oldsubject.conditions;
    else
        intersection = intersect(study.blocks, oldsubject.blocks);
        if(isempty(intersection))
            subject.blocks = study.blocks;
        else
            subject.blocks = intersection;
        end
    end
else
    subject.blocks = study.blocks;
end

% projfile (formerly projections_file)
if(past & isfield(oldsubject, 'meg') & isfield(oldsubject.meg, 'projfile') & ~isempty(oldsubject.meg.projfile))
    subject.meg.projfile = oldsubject.meg.projfile;
else
    subject.meg.projfile = '';
end

% For the eog file, complete the filename if not already completed
dashes = strfind(subject.meg.projfile, '/');
if(isempty(dashes))
    subject.meg.projfile = sprintf('%s/%s', gps_filename(subject, 'meg_scan_dir'), subject.meg.projfile);
end

%% Behavioral Fields

% trialdata
if(past & isfield(oldsubject,'meg') & isfield(oldsubject.meg,'behav') & isfield(oldsubject.meg.behav,'trialdata') & ~isempty(oldsubject.meg.behav.trialdata))
    subject.meg.behav.trialdata = oldsubject.meg.behav.trialdata;
else
    subject.meg.behav.trialdata = struct([]);
end

% responses
if(past & isfield(oldsubject,'meg') & isfield(oldsubject.meg,'behav') & isfield(oldsubject.meg.behav,'responses') & ~isempty(oldsubject.meg.behav.responses))
    subject.meg.behav.responses = oldsubject.meg.behav.responses;
elseif(past & isfield(oldsubject,'behav') & isfield(oldsubject.behav,'responses') & ~isempty(oldsubject.behav.responses))
    subject.meg.behav.responses = oldsubject.behav.responses;
else
    subject.meg.behav.responses = [0 0; 0 0];
end

% rts
if(past & isfield(oldsubject,'meg') & isfield(oldsubject.meg,'behav') & isfield(oldsubject.meg.behav,'rts') & ~isempty(oldsubject.meg.behav.rts))
    subject.meg.behav.rts = oldsubject.meg.behav.rts;
elseif(past & isfield(oldsubject,'behav') & isfield(oldsubject.behav,'rts') & ~isempty(oldsubject.behav.rts))
    subject.meg.behav.rts = oldsubject.behav.rts;
else
    subject.meg.behav.rts = [];
end

% N_trials
if(past & isfield(oldsubject,'meg') & isfield(oldsubject.meg,'behav') & isfield(oldsubject.meg.behav,'N_trials') & ~isempty(oldsubject.meg.behav.N_trials))
    subject.meg.behav.N_trials = oldsubject.meg.behav.N_trials;
elseif(past & isfield(oldsubject,'behav') & isfield(oldsubject.behav,'N_trials') & ~isempty(oldsubject.behav.N_trials))
    subject.meg.behav.N_trials = oldsubject.behav.N_trials;
else
    subject.meg.behav.N_trials = 0;
end

% N_missed
if(past & isfield(oldsubject,'meg') & isfield(oldsubject.meg,'behav') & isfield(oldsubject.meg.behav,'N_missed') & ~isempty(oldsubject.meg.behav.N_missed))
    subject.meg.behav.N_missed = oldsubject.meg.behav.N_missed;
elseif(past & isfield(oldsubject,'behav') & isfield(oldsubject.behav,'N_missed') & ~isempty(oldsubject.behav.N_missed))
    subject.meg.behav.N_missed = oldsubject.behav.N_missed;
elseif(past & isfield(oldsubject,'behav') & isfield(oldsubject.behav,'trials_missed') & ~isempty(oldsubject.behav.trials_missed))
    subject.meg.behav.N_missed = oldsubject.behav.trials_missed;
else
    subject.meg.behav.N_missed = 0;
end

%% MNE Fields

% dir
if(past & isfield(oldsubject,'mne') & isfield(oldsubject.mne,'dir') & ~isempty(oldsubject.mne.dir) & oldsubject.mne.dir ~= 0)
    subject.mne.dir = oldsubject.mne.dir;
else
    subject.mne.dir = sprintf('%s/%s', study.mne.dir, subject.name);
end

% avefile
if(past & isfield(oldsubject,'mne') & isfield(oldsubject.mne,'avefile') & ~isempty(oldsubject.mne.avefile))
    subject.mne.avefile = oldsubject.mne.avefile;
elseif(past & isfield(oldsubject,'meg') & isfield(oldsubject.meg,'avefile') & ~isempty(oldsubject.meg.avefile))
    subject.mne.avefile = oldsubject.meg.avefile;
else
    subject.mne.avefile = sprintf('%s/%s_ave.fif', subject.mne.dir, subject.name);
end

% covfile
if(past & isfield(oldsubject,'mne') & isfield(oldsubject.mne,'covfile') & ~isempty(oldsubject.mne.covfile))
    subject.mne.covfile = oldsubject.mne.covfile;
elseif(past & isfield(oldsubject,'meg') & isfield(oldsubject.meg,'covfile') & ~isempty(oldsubject.meg.covfile))
    subject.mne.covfile = oldsubject.meg.covfile;
else
    subject.mne.covfile = sprintf('%s/%s_cov.fif', subject.mne.dir, subject.name);
end

% fwdfile
if(past & isfield(oldsubject,'mne') & isfield(oldsubject.mne,'fwdfile') & ~isempty(oldsubject.mne.fwdfile))
    subject.mne.fwdfile = oldsubject.mne.fwdfile;
elseif(past & isfield(oldsubject,'meg') & isfield(oldsubject.meg,'fwdfile') & ~isempty(oldsubject.meg.fwdfile))
    subject.mne.fwdfile = oldsubject.meg.fwdfile;
else
    subject.mne.fwdfile = sprintf('%s/%s-fwd.fif', subject.mne.dir, subject.name);
end

% invfile
if(past & isfield(oldsubject,'mne') & isfield(oldsubject.mne,'invfile') & ~isempty(oldsubject.mne.invfile))
    subject.mne.invfile = oldsubject.mne.invfile;
elseif(past & isfield(oldsubject,'meg') & isfield(oldsubject.meg,'invfile') & ~isempty(oldsubject.meg.invfile))
    subject.mne.invfile = oldsubject.meg.invfile;
else
    subject.mne.invfile = sprintf('%s/%s-inv.fif', subject.mne.dir, subject.name);
end

%% PLV

% sample_rate
if(past & isfield(oldsubject,'plv') & isfield(oldsubject.plv,'sample_rate') & ~isempty(oldsubject.plv.sample_rate))
    subject.plv.sample_rate = oldsubject.plv.sample_rate;
else
    subject.plv.sample_rate = 1000;
end

% sample_times
if(past & isfield(oldsubject,'plv') & isfield(oldsubject.plv,'sample_times') & ~isempty(oldsubject.plv.sample_times))
    subject.plv.sample_times = oldsubject.plv.sample_times;
else
    subject.plv.sample_times = [];
end

%% Update Last Edited
subject.last_edited = datestr(now, 'yyyymmdd_HHMMSS');

end % function
