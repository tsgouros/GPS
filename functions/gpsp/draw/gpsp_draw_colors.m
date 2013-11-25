function color = gpsp_draw_colors(designation)
% Translate a designation to a color value
%
% Author: A. Conrad Nied (conrad.logos@gmail.com)
%
% Changelog:
% 2013-08-06 Created

if(isnumeric(designation))
    designation = num2str(designation);
end

switch lower(designation)
    case {'1', 'white'}
        color = [1 1 1];
    case {'2', 'grey'}
        color = [0.8 0.8 0.8];
    case {'3', 'gray'}
        color = [.5 .5 .5];
    case {'4', 'black'}
        color = [0 0 0];
    case {'5', 'red'}
        color = [1 0 0];
    case {'6', 'yellow'}
        color = [1 1 0];
    case {'7', 'green'}
        color = [0 1 0];
    case {'8', 'cyan'}
        color = [0 1 1];
    case {'9', 'blue'}
        color = [0 0 1];
    case {'10', 'magenta'}
        color = [1 0 1];
    case {'11', 'orange'}
        color = [1 .5 0];
    otherwise
        color = [0 0 0];
end % switch

end % color