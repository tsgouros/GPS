function inv = gpsa_mne_getinv(varargin)
% Loads the inverse file
%
% Author: A. Conrad Nied (conrad.logos@gmail.com)
%
% Inputs (in any order):
%  Inverse fif filename as string OR
%  Subject structure, with the inverse fif filename OR
%  State structure, with subject field to retrieve the inverse filename
% 
% Changelog:
% 2012.10.30 - Created

%% Set presets and handle any inputs

snr = 5;
dSPM = 0;

for i_argin = 1:nargin
    parameter = varargin{i_argin};
    
    if(isnumeric(parameter))
        snr = parameter;
    elseif(isstruct(parameter) && strcmp(parameter.name, 'state'))
        subject = gpsa_parameter(parameter, parameter.subject);
        invfile = subject.mne.invfile;
    elseif(isstruct(parameter) && strcmp(parameter.type, 'subject'))
        invfile = parameter.mne.invfile; %#ok<*NASGU>
    elseif(ischar(parameter))
%         if(strcmp(parameter, 'dSPM'))
%             dSPM = 1;
%         else
            invfile = parameter;
%         end
    end
end

%% Get the inverse operator
[~, inv] = evalc('mne_read_inverse_operator(invfile)');

% Prepares other information for the inverse operator
lambda2 = 1 / (snr * snr); %#ok<NASGU>
[~, inv] = evalc('mne_prepare_inverse_operator(inv, inv.nave, lambda2, 1)');

end % function