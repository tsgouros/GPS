function [hue, chroma, luma] = rgb2hcy(red, green, blue)
% Converts RGB color values to Conrad Nied's colorspace
%
% Author: A. Conrad Nied (conrad@martinos.org)
%
% Changelog:
% 2013.05.28 - Created

%% Transform RGB space to approximate perceptual colorspace
transform = [  1      -1/2       -1/2;... Red versus other colors
               0 sqrt(3)/2 -sqrt(3)/2;... Green versus blue
             1/3       1/2        1/6]; % Lightness
         
result = transform * [red green blue]';

red_cyan   = result(1, :)';
green_blue = result(2, :)';
luma       = result(3, :)'; % Simplification of Standard Definition CCIR 601
    
%% Transform cartesian to polar

% Circumference
hue = atan2(green_blue, red_cyan);

% Amplify the power of the Red-Yellow segment to reflect perceptual bias
tau = 2 * pi;
hue = mod(hue, tau); % Align indices to start a 0

hue_shift = hue;
hue_shift(hue < tau/6) = hue(hue < tau/6) * 6*2/7; 
hue_shift(hue >= tau/6) = (hue(hue >= tau/6) - tau/6) * 6/7 + 2/7*tau; 
hue = hue_shift;

hue(hue > pi) = -tau + hue(hue > pi); % Align back

% Radius
chroma = sqrt(red_cyan .^ 2 + green_blue .^ 2);

end % function