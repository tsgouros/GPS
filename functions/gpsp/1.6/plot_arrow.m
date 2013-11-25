function plot_arrow(A, B, varargin)
% Draws an arrow, specifically for the granger plot needs
%
% Author: Conrad Nied
%
% Input: The two points the arrow is being drawn from as well as more
% options
% Output: Draws the arrow on the target axes window 
%
% Date Created: 2012.08.07 from granger_plot_arrow
% Last Modified: 2012.08.07

%% Parameters

% Defaults
color = [0 1];
border = '-';
brain = false;
style = 'Terminal';
recip = false; % Reciprocal

for i_argin = 1:2:length(varargin)
    parameter = varargin{i_argin};
    parameter_spec = varargin{i_argin+1};
    
    % Specify which step(s) we are looking at
    switch parameter
        case {'Axes', 'Parent', 'axes', 'Axis', 'axis', 'parent'}
            axes = parameter_spec;
        case {'LineStyle', 'Border', 'border', 'linestyle'}
            border = parameter_spec;
        case {'Color', 'color'}
            color = parameter_spec;
        case {'Reciprocal', 'reciprocal', 'Recip', 'recip'}
            recip = parameter_spec;
        case {'Brain', 'brain'}
            brain = parameter_spec;
        case {'Circle', 'circle'}
            brain = ~parameter_spec;
        case {'Surface', 'surface', 'surf'}
            if(isnumeric(parameter_spec))
                parameter_spec = num2str(parameter_spec);
            end
            switch parameter_spec
                case {'0', 'Circle', 'circle'}
                    brain = false;
                case {'1', 'Brain', 'brain', 'Brain - Inflated', 'Brain - Pial', 'inf', 'pial'}
                    brain = true;
                otherwise
                    brain = false;
            end
        case {'Style', 'style'}
            if(isnumeric(parameter_spec))
                parameter_spec = num2str(parameter_spec);
            end
            
            switch parameter_spec
                case {'1', 'Terminal Wedge', 'Terminal', 'terminal'}
                    style = 'Terminal';
                case {'2', 'Interior Arrows', 'Interior'}
                    style = 'Interior';
                case {'3', 'Rectangle'}
                    style = 'Rectangle';
                otherwise
                    style = 'Terminal';
            end
        case {'Width', 'width'}
            width = parameter_spec;
        case {'Width_tri', 'width_tri', 'Triangle Width'}
            width_tri = parameter_spec;
        otherwise
            fprintf('Unknown specification %s', parameter)
            return;
    end
end

if(~exist('axes', 'var'))
    axes = gca;
end

% A few more defaults that could depend on other values
h = norm(A - B);

if(~exist('width', 'var'))
    width = h / 4;
end
if(~exist('width_tri', 'var'))
    width_tri = width * 2;
end

%% Construct Arrow Points on simple plane
%
% Arrow looks like this ====>
%
% Points arranged are each inflection point.
% A is the source, B is the destination
% The arrow is the points ACDEBFGH according to my diagram.

% If we are using the brain, remove the X coordinates to be readded later
if(brain)
    Ax = A(1);
    A(1) = [];
    Bx = B(1);
    B(1) = [];
else
    if(length(A) == 3)
        Az = A(3);
        A(3) = [];
        Bz = B(3);
        B(3) = [];
    else
        Az = 0;
        Bz = 0;
    end
end

% Depending on the style, automatically fix the width of the triangle wedge
if(strcmp(style, 'Interior') || strcmp(style, 'Rectangle'))
    width_tri = 0;
end

% Make two widths if there were only one, for each side of the arrow
if(length(width) == 1);
    width = [width width] / 2;
end
if(length(width_tri) == 1);
    width_tri = [width_tri width_tri];
end

h_tri = sin(pi/3) * width_tri; % Presuming the triangle is equilateral
h_rect = h - h_tri;
C = [0 width(1)];
D = [h_rect(1) width(1)];
E = [h_rect(1) width_tri(1) / 2];
F = [h_rect(2) -width_tri(2) / 2];
G = [h_rect(2) -width(2)];
H = [0 -width(2)];

if(recip)
    F = [h_tri(2) -width_tri(2) / 2];
    G = [h_tri(2) -width(2)];
    H = [h -width(2)];
end

%% Rotate Points and Offset to align with given points
% Rotate
%-- determine angle for the rotation of the triangle
if B(1) == A(1)
    if B(2) > A(2)
        theta = pi/2;
    else
        theta = -pi/2;
    end
else
    % Find slope first
    m = (B(2) - A(2)) / (B(1) - A(1));
    if B(1) > A(1), %-- now calculate the resulting angle
        theta = atan(m);
    else
        theta = atan(m) + pi;
    end
end

rotate = [cos(theta) -sin(theta); sin(theta) cos(theta)];
C = rotate * C';
D = rotate * D';
E = rotate * E';
F = rotate * F';
G = rotate * G';
H = rotate * H';

% Offset
A = A;
C = C' + A;
D = D' + A;
E = E' + A;
B = B;
F = F' + A;
G = G' + A;
H = H' + A;

%% Project into 3D space

% If we are on the brain surface, readd the x coordinate
if(brain)
    A = [Ax A];
    C = [Ax C];
    D = [Bx D];
    E = [Bx E];
    B = [Bx B];
    F = [Bx F];
    G = [Bx G];
    H = [Ax H];
else % Otherwise add an empty z
    A = [A Az];
    C = [C Az];
    D = [D Bz];
    E = [E Bz];
    B = [B Bz];
    F = [F Bz];
    G = [G Bz];
    H = [H Az];
end

%% Configure color
if(length(color) == 2) % Do we have an interpolating color?
    cA = color(2);
    cB = color(1);
else
    cA = color;
    cB = color;
end

if(strcmp(style, 'Interior'))
    cC = cA + (cB - cA) * (width(1) + width(2)) / h / 2;
    cD = cB;
    cE = cB;
    cB = cA + (cB - cA) * (1 - (width(1) + width(2)) / h / 2);
    cF = cE;
    cG = cD;
    cH = cC;
else
    cC = cA;
    cD = cB;
    cE = cB;
    cF = cE;
    cG = cD;
    cH = cC;
end

%% Draw Arrow

% Make arrow object
FV.vertices        = [ A;  C;  D;  E;  B;  F;  G;  H];
FV.facevertexcdata = [cA; cC; cD; cE; cB; cF; cG; cH];
if(strcmp(style, 'Interior'))
    if(recip)
        FV.vertices        = [ A;  C;  D;  E;  B;  B;  H;  G;  F;  A];
        FV.facevertexcdata = [cA; cC; cD; cE; cB; cA; cH; cG; cF; cB];
        FV.faces           = [1 2 5; 2 3 5; 3 4 5; 6 7 10; 7 8 10; 8 9 10];
    else
        FV.faces           = [1 2 5; 2 3 5; 3 4 5; 5 6 7; 5 7 8; 5 8 1];
    end
else
    if(recip)
        FV.vertices        = [ A;  C;  D;  E;  B;  B;  H;  G;  F;  A];
        FV.facevertexcdata = [cA; cC; cD; cE; cB; cA; cH; cG; cF; cB];
        FV.faces           = [1 2 3 4 5; 6 7 8 9 10];
    else
        FV.faces           = [1 2 3 4 5 6 7 8];
    end
end

% Draw
patch(FV,...
    'FaceColor', 'interp',...
    'Parent', axes,...
    'LineStyle', border,...
    'FaceLighting', 'none');

end