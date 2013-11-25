function varargout = gpsa_util_bem(varargin)
% Visualizes the skull surfaces
%
% Author: A. Conrad Nied (conrad.logos@gmail.com)
%
% Changelog:
% 2013.06.18 - Created
% 2013.07.02 - Updated status check for gps_filename
% 2013.07.08 - Doesn't mark as finished now so it can always be redone

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
    state.function = 'gpsa_util_bem';
    tbegin = tic;
    
    % Load the surfaces
    [brain_coords, brain_face] = read_surf([subject.mri.dir '/bem/brain.surf']);
    [inner_coords, inner_face] = read_surf([subject.mri.dir '/bem/inner_skull.surf']);
    [outer_coords, outer_face] = read_surf([subject.mri.dir '/bem/outer_skull.surf']);
    [skin_coords,  skin_face ] = read_surf([subject.mri.dir '/bem/outer_skin.surf']);
    
    % Set up the figure
    figure(478948)
    clf
    axes = gca;
    
    % Draw the brain
    patch('Parent', axes,...
        'Faces', brain_face + 1,...
        'Vertices', brain_coords,...
        'FaceColor', [0.5 0.5 0.5],...
        'MarkerEdgeColor', 'none',...
        'EdgeColor', 'none',...
        'FaceAlpha', 1,...
        'FaceLighting', 'flat',...
        'SpecularStrength', 0.0, 'AmbientStrength', 0.4,...
        'DiffuseStrength', 0.8, 'SpecularExponent', 10.0);
    
    % Draw the inner skull
    patch('Parent', axes,...
        'Faces', inner_face + 1,...
        'Vertices', inner_coords,...
        'FaceColor', [0.8 0.5 0.5],...
        'MarkerEdgeColor', 'none',...
        'EdgeColor', 'none',...
        'FaceAlpha', 0.5,...
        'FaceLighting', 'flat',...
        'SpecularStrength', 0.0, 'AmbientStrength', 0.4,...
        'DiffuseStrength', 0.8, 'SpecularExponent', 10.0);
    
    % Draw the outer skull
    patch('Parent', axes,...
        'Faces', outer_face + 1,...
        'Vertices', outer_coords,...
        'FaceColor', [0.5 0.5 0.8],...
        'MarkerEdgeColor', 'none',...
        'EdgeColor', 'none',...
        'FaceAlpha', 0.5,...
        'FaceLighting', 'flat',...
        'SpecularStrength', 0.0, 'AmbientStrength', 0.4,...
        'DiffuseStrength', 0.8, 'SpecularExponent', 10.0);
    
    % Draw the outer skin
    patch('Parent', axes,...
        'Faces', skin_face + 1,...
        'Vertices', skin_coords,...
        'FaceColor', [0.5 0.8 0.5],...
        'MarkerEdgeColor', 'none',...
        'EdgeColor', 'none',...
        'FaceAlpha', 0.2,...
        'FaceLighting', 'flat',...
        'SpecularStrength', 0.0, 'AmbientStrength', 0.4,...
        'DiffuseStrength', 0.8, 'SpecularExponent', 10.0);
    
    % Lighting and Perspective
    azimuth = 137;
    elevation = 6;
    view(azimuth, elevation);
    [lightx, lighty, lightz] = sph2cart(azimuth * pi / 180, elevation * pi / 180, 100);
    light('Parent', axes,...
        'Position', [lighty -lightx lightz],...
        'Style', 'infinite');
    
    % Turn on rotation
    rotate3d on
    axis('equal');
    
    % Take a picture
    filename = sprintf('%s/bem/bem.png', subject.mri.dir);
    frame = getframe(478948);
    imwrite(frame.cdata, filename, 'png');
    
    % Record the process
    gpsa_log(state, toc(tbegin));
    
end % If we should do the function

%% Add to the report concerning the progress

if(~isempty(strfind(operation, 'p')))
    % Prerequisite: gpsa_mri_bem
    subject = gpsa_parameter(state, state.subject);
    report.ready = ~isempty(dir(gps_filename(subject, 'mri_bem_surf_gen')));
    filename = sprintf('%s/bem/bem.png', subject.mri.dir);
    report.progress = ~~exist(filename, 'file');
    report.finished = (report.progress == 1) * 0.9;
end

%% Prepare the report and output

if(nargout == 1 && exist('report', 'var'));
    varargout{1} = report;
end


end % function