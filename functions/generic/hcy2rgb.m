function [red, green, blue] = hcy2rgb(hue, chroma, luma)
% Converts Conrad Nied's colorspace color values to RGB
%
% Author: A. Conrad Nied (conrad@martinos.org)
%
% Changelog:
% 2013.05.28 - Created

%% Even out Hue alignment

% Align hue to be from 0 to tau
tau = 2 * pi;
hue = mod(hue, tau); % Align indices to start a 0

% Shift the red-yellow segment to computer production size
hue_shift = hue;
hue_shift(hue < 2/7*tau) = hue(hue < 2/7*tau) * 7/(6*2); 
hue_shift(hue >= 2/7*tau) = (hue(hue >= 2/7*tau) - 2/7*tau) * 7/6 + 1/6*tau; 

% Align back to -pi to pi
hue_shift(hue_shift > pi) = -tau + hue_shift(hue_shift > pi); % Align back

%% Determine original perceptual colorspace dimensions

% Get color dimensions
red_cyan   = cos(hue_shift) .* chroma;
green_blue = sin(hue_shift) .* chroma;

%% Transform to RGB colorspace
transform = 1/3 * [ 2 -1/(sqrt(3)) 3;... Red
                   -1  2/(sqrt(3)) 3;... Green
                   -1 -4/(sqrt(3)) 3]; % Blue
         
result = transform * [red_cyan green_blue luma]';

red   = result(1, :)';
green = result(2, :)';
blue  = result(3, :)';

end % function