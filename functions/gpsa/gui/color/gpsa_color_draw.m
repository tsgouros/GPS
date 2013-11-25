function gpsa_color_draw
% Draws the colors for status in for GPS: Analysis
%
% Author: A. Conrad Nied (conrad.logos@gmail.com)
%
% Changelog:
% 2012.10.03 - Created
% 2012.11.12 - Accounts for near complete ready/progress
% 2013.07.08 - In GPS1.8, added done but "unfinished" coloring

state = gpsa_get;
status = state.gui.status;

%% Color the stages by completion level

stages = gps_presets('stages');
for i_stage = 1:length(stages)
    stage = stages{i_stage};
    axis_name = sprintf('s%d_status', i_stage);
    
    % Get stage parameters
    functions = fields(status.(stage));
    N_functions = length(functions);
    ready = 0;
    progress = 0;
    finished = 0;
    applicable = 0;
    
    % Gather the function readiness/progress
    for i_function = 1:N_functions
        func = functions{i_function};
        divisor = status.(stage).(func).applicable;
        if(divisor == 0); divisor = 1; end
        ready = ready + status.(stage).(func).ready / divisor;
        progress = progress + status.(stage).(func).progress / divisor;
        finished = finished + status.(stage).(func).finished / divisor;
        applicable = applicable + status.(stage).(func).applicable / divisor;
%         fprintf('%s\t%s\t%f\t%f\t%f\t%f\n', stage, func, ready, progress, finished, divisor);
    end % for all functions of the stage
    
    if(applicable > 0)
        ready = ready / applicable; progress = progress / applicable; finished = finished / applicable;
        
        % Render Gradient
        if(state.override); finished = 0; end
        img = render(ready, progress, finished);
    else
        img = zeros(10, 50, 3);
    end
    
    % Draw into the GUI
    imshow(img, 'Parent', state.gui.(axis_name));
    axis(state.gui.(axis_name), 'normal');
end % for all stages

%% Color the displayed functions by completion level

stage = state.stage;
functions = eval(['gpsa_' stage '_functions']);

for i_function = 1:length(functions)
    axis_name = sprintf('f%d_status', i_function);
    func = functions{i_function};
    
    % Gather the function readiness/progress
    divisor = status.(stage).(func).applicable;
    if(divisor > 0)
        ready = status.(stage).(func).ready / divisor;
        if(ready < 1 && ready > 0); ready = ready + 0.000001; end
        progress = status.(stage).(func).progress / divisor;
        if(progress < 1 && progress > 0); progress = progress + 0.000001; end
        finished = status.(stage).(func).finished / divisor;
        if(finished < 1 && finished > 0); finished = finished + 0.000001; end
        %     fprintf('%s\t%20s\t%f\t%f\t%f\t%f\n', stage, func, ready, progress, finished, divisor);
        
        % Render Gradient
        if(state.override); finished = 0; end
        img = render(ready, progress, finished);
    else
        img = zeros(10, 50, 3);
    end
    
    % Draw into the GUI
    imshow(img, 'Parent', state.gui.(axis_name));
    axis(state.gui.(axis_name), 'normal');
end % for all stages

end % function

function img = render(ready, progress, finished)

% Ready bar is yellow to green
if(ready < 1)
    red = 1 : -1 / 49 : 1 - ready;
    readybar = cat(3, repmat(red, 10, 1), ones(10, length(red)), zeros(10, length(red)));
    readybar = cat(2, readybar, ones(10, 50 - length(red), 3) * 0.8);
else
    if(progress < 1)
        readybar = cat(3, zeros(10, 50), ones(10, 50), zeros(10, 50));
    else
        if(finished >= 1)
            readybar = cat(3, zeros(10, 50), zeros(10, 50), ones(10, 50));
        else
            readybar = cat(3, ones(10, 50)*0.5, zeros(10, 50), ones(10, 50));
        end
    end
end

% Progress bar is green to blue
if(progress < 1)
    blue = 0 : 1 / 49 : progress;
    green = 1 - blue;
    progbar = cat(3, zeros(10, length(blue)), repmat(green, 10, 1), repmat(blue, 10, 1));
    progbar = cat(2, progbar, ones(10, 50 - length(blue), 3) * 0.8);
else
    if(finished >= 1)
        progbar = cat(3, zeros(10, 50), zeros(10, 50), ones(10, 50));
    else
        progbar = cat(3, ones(10, 50)*0.5, zeros(10, 50), ones(10, 50));
    end
end

img = cat(1, readybar, progbar);

% Render bounding box over the gradient
img(:, 1, :)   = 0.5;
img(:, end, :) = 0.5;
img(end, :, :) = 0.5;
img(1, :, :)   = 0.5;

% Mask to smooth out display

end