function num = gpsa_mne_avefifnum(state)
% Gets the number of the condition in the average fif file
%
% Author: A. Conrad Nied (conrad.logos@gmail.com)
%
% Changelog:
% 2013.04.26 - Created in GPS1.8
% 2019.01-03 - Added explicit pathname references to environment vars.  -tsg


subject = gpsa_parameter(state, state.subject);
 %% Added explicit mnehome reference.  -tsg  
unix_command = sprintf('%s/bin/mne_show_fiff --verbose --indent 1 --in %s | grep "    206 = comment"', state.mnehome, subject.mne.avefile);
[~, results] = unix(unix_command);

num = 1;
while(~isempty(results))
    i = find(results + 0 == 9, 1, 'first');
    j = find(results + 0 == 10, 1, 'first');
    if(~isempty(i) && ~isempty(j) && j > i)
        condition = results(i+1:j-1);
         if(strcmp(state.condition, condition))
             return
         else
             num = num + 1;
         end
         
         results = results(j+1:end);
    end % if
end % while

% Not found, so return 0
num = 0;

end % function
