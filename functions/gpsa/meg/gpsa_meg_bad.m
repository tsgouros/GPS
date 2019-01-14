function varargout = gpsa_meg_bad(varargin)
% Records and applies bad channel information
%
% Author: A. Conrad Nied (conrad.logos@gmail.com)
%
% Changelog:
% 2011.11.28 - Originally created as GPS1.6(-)/meg_bad.m
% 2012.02.21 - Last modified in GPS1.6(-)
% 2012.10.03 - Updated to GPS1.7 format
% 2013.01.10 - Fixed incompatiblity with updated MEG electronics and made
% readout less disconcerting.
% 2013.04.11 - GPS 1.8, Updated the status check to the new system
% 2013.04.24 - Changed subset/subsubset to condition hierarchy
% 2013.04.30 - Gets filenames from gps_filename now
% 2013.07.10 - Tries to mark all .fif files now instead of just the raw ones.

%% Input

[state, operation] = gpsa_inputs(varargin);

%% Prepare a report on the type or progress of the data

if(~isempty(strfind(operation, 't')))
    report.spec_subj = 1; % Subject specific?
    report.spec_cond = 0; % Condition specific?
end

%% Execute the process

if(~isempty(strfind(operation, 'c')))

    subject = gpsa_parameter(state.subject);
    state.function = 'gpsa_meg_bad';
    tbegin = tic;

    % Set dialog defaults
    prompt_default = {num2str(subject.meg.bad_eeg), num2str(subject.meg.bad_meg)};
    options.Resize = 'on';

    prompt_selection = inputdlg({'Bad EEG', 'Bad MEG'},...
        'Please List the Bad Channels',...
        1, prompt_default, options);

    % Exit if no answer given
    if(isempty(prompt_selection))
        return;
    end

    % Convert string input to data
    if ~isempty(prompt_selection{1})
        temp = textscan(prompt_selection{1}, '%d', 'Delimiter', ', ', 'MultipleDelimsAsOne', 1);
        subject.meg.bad_eeg = temp{1}';
    else
        subject.meg.bad_eeg = [];
    end

    if ~isempty(prompt_selection{2})
        temp = textscan(prompt_selection{2}, '%d', 'Delimiter', ', ', 'MultipleDelimsAsOne', 1);
        subject.meg.bad_meg = temp{1}';
    else
        subject.meg.bad_meg = [];
    end

    % 2) Write to bad channels file
    usespace = ' '; % Try with and without a space
    for attempt = 1:2

        % Start File
        badchannel_file = gps_filename(subject, 'meg_channels_bad');
        fid = fopen(badchannel_file, 'w');

        % Write each bad channel
        for i_eeg = 1:length(subject.meg.bad_eeg)
            fprintf(fid, 'EEG%s%03d\n', usespace, subject.meg.bad_eeg(i_eeg));
        end
        for i_meg = 1:length(subject.meg.bad_meg)
            fprintf(fid, 'MEG%s%04d\n', usespace, subject.meg.bad_meg(i_meg));
        end

        fclose(fid);

        % 3) Run the command to mark bad channels
        unix_command = sprintf('%s/bin/mne_mark_bad_channels --bad %s %s',...
                               state.mnehome,...  % explicit mnehome ref  -tsg
                               badchannel_file,...
                               gps_filename(subject, 'meg_fif_gen'));
        [~, output] = unix(unix_command);

        fprintf(output);

        % Only say done files rather than the whole input
        fprintf('\tMarked in:\n');
        done = strfind(output, '[done]');
        for i = 1:length(done);
            fprintf('\t\t%s\n', output(find(output(1:done(i)) == '/', 1, 'last') + 1 : done(i) - 6));
        end % for each file it got bad channels out of

        % Try a different channel name format if the first try didn't work
        if(strfind(output, 'No channel called'))
            usespace = '';
        else
            break;
        end
    end

    % Record the process
    gpsa_parameter(state, subject);
    gpsa_log(state, toc(tbegin));

end % If we should do the function

%% Add to the report concerning the progress

if(~isempty(strfind(operation, 'p')))
    subject = gpsa_parameter(state, state.subject);
    report.ready = ~isempty(dir(gps_filename(subject, 'meg_scan_gen')));
    report.progress = ~isempty(dir(gps_filename(subject, 'meg_channels_bad')));
    report.finished = report.progress == 1;
end

%% Prepare the report and output

if(nargout == 1 && exist('report', 'var'));
    varargout{1} = report;
end

end % function
