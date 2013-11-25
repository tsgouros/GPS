function [distances, lasthop] = gpsp_dijkstra(index, adjacent, adjacent_dist)
% Computes the distance sheet from the index point to the rest of the
% coordinates
%
% Author: Conrad Nied
%
% Changelog:
% 2013.02.13 - Created, based on popalgo/dist_dijkstra.m

N = size(adjacent, 1);
clear data

% Initialize matrices
distances = ones(N, 1, 'single') * 1e18;
lasthop = zeros(N, 1, 'uint32');
found = false(N, 1);

% Find the original vertex
found(index) = 1;
distances(index) = 0;

% Get neighbors
vertices = adjacent(index, :)';

% Insert its neighbors
distance_new = adjacent_dist(index, :)';
distance_new = distances(index) + distance_new;
select = distances(vertices) > distance_new;
distances(vertices(select)) = distance_new(select);
lasthop(vertices(select)) = index;

% Only look at the border (to speed things up, size(border) is much less
% than N
border = vertices;

% Interate for the rest of the graph
while(sum(~found))
    
    % Update progress
%     if(mod(sum(found), 10000) == 1000)
%         fprintf('\n\t%3d ', sum(found)/1000);
%         imageshow = reshape(distances, sqrt(N/2), sqrt(2*N));
%         imageshow(imageshow == 1e18) = 0;
%         imageshow = imageshow ./ max(imageshow(:));
%         imshow(imageshow);
%         pause;
%     elseif(mod(sum(found), 1000) == 0)
%         fprintf('%3d ', sum(found)/1000);
%     end
    
    % Find closest unfound vertex
%     [~, index] = min(distances + found * N);
%     found(index) = 1;
    [~, min_i] = min(distances(border));
    index = border(min_i); % Get the overall vertex number
    border(min_i) = []; % remove it from the border
    found(index) = 1; % Mark it as found
    
    % Get neighbors
    vertices = adjacent(index, :)';
    
    % Exclude already found neighbors
    select = find(~found(vertices));
    vertices = vertices(select);
    
    % Get the local distance
    distance_new = adjacent_dist(index, select)';
    
    % Get overall distance
    distance_new = distances(index) + distance_new;
    
    % Find closer distances and replace their distance values
    select = distances(vertices) > distance_new;
    distances(vertices(select)) = distance_new(select);
    lasthop(vertices(select)) = index;
    
    % Add the vertices back to the border
    border = unique([border; vertices]);
end
% 
% fprintf('\n');
% fprintf('\t%5f s\n', toc);

end % function