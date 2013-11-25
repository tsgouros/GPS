function str = str_unbold(str)
% Removes <b> tags from a string if they exist
%
% Author: A. Conrad Nied
%
% 2013.04.25

% if(length(str) >= 7 && strcmp(str(1:3), '<b>') && strcmp(str(end-3:end), '</b>'))
%     str = str(4:end-4);
% end % if
if(length(str) >= 11 && strcmp(str(1:9), '<html><b>') && strcmp(str(end-10:end), '</b></html>'))
    str = str(10:end-11);
end % if

end