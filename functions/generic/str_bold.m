function str = str_bold(str)
% Adds <b> tags to a string but not redundantly
%
% Author: A. Conrad Nied
%
% 2013.04.25
% 
% if(~(length(str) >= 7 && strcmp(str(1:3), '<b>') && strcmp(str(end-3:end), '</b>')))
%     str = sprintf('<b>%s</b>', str);
% end % if
if(~(length(str) >= 11 && strcmp(str(1:9), '<html><b>') && strcmp(str(end-10:end), '</b></html>')))
    str = sprintf('<html><b>%s</b></html>', str);
end % if

end