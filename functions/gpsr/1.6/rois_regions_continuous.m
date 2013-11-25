function indices = rois_regions_continuous(coords, threshold, N_max)
% From coordinates finds the index of the region starting at the first
% point
%
% Author: Conrad Nied
%
% Based on: continuous_region by Conrad Nied version dated 2011.10.04
% Date Created: 2012.06.26
% Last Modified: 2012.06.26
% 2013.06.28 - GPS1.8, doesn't draw the figures if autoredraw is off

% Parameters
if(~exist('threshold', 'var'))
    threshold = 1; end
if(~exist('N_max', 'var'))
    N_max = 10000; end
flag_figures = 0;

% threshold = 1; % 1 mm radius
N = size(coords, 1);

if(flag_figures)
    figure(alphahash('cont'))
    clf
    scatter3(coords(:,1), coords(:,2), coords(:,3))
    hold on
    title('Continous Region Point');
end

A = []; % Accepted points
B = 1; % BFS queue: newly accepted points, waiting to be scanned for neighbors
C = (2:N)'; % candidates

N_B = 1;
% Iteratively go through all candidate points and add its neighbors that
% are close enough to be considered continuous
while(N_B >= 1 && length(A) < N_max)
    point = B(1);
    B(1) = [];
    
    dist = distL2(coords(point,:),coords(C,:));
    B_add = C(dist<threshold);
    C = setdiff(C, B_add);
    B = [B; B_add];
    A = [A; point];
    
    N_B = length(B);
end

indices = A;

if(flag_figures)
    plot3(coords(indices, 1), coords(indices, 2), coords(indices, 3), 'kx', 'MarkerSize', 10)
    plot3(coords(1, 1), coords(1, 2), coords(1, 3), 'c+', 'MarkerSize', 10)
end

end % Function