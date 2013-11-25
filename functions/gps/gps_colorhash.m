function color = gps_colorhash(index)
% Converts indices to colors
%
% Author: Conrad Nied
%
% Changelog
% 2012.08.17 - Created
% 2012.10.12 - Imported to GPS1.7

color = [mod(index * 1000 + 1, 255), mod(index * 100 + 1, 255), mod(index * 10 + 1, 255)];

end % function