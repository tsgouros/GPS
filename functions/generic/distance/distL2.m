%% Distance (Second Laplacian Norm)

% This function returns the second Lebesgue
% norm of two vectors, this norm is commonly
% referred to as the Euclidean distance. It is
% the sum of the squares of the distances on
% each dimension. If the second vector is a
% matrix it will return a vector of all of the
% distances from each row vectors in this
% matrix to the first.

% Author: A. Conrad Nied, 2011.08.15 - 09.14
 
%% Inputs
% vector A, vector OR matrix B

%% Outputs
% distance from A to B
% OR
% array of distances from A to vectors in B.

%% Example:
% distL2([1 0],[3 0; 4 4; 2 1]) = [2; 5; 1.4142]
 
%% Future:
% This function is pretty basic and
% stable. If non-euclidean distances are wanted
% I can make more distance functions but for
% our purposes we will use euclidean distances.
% (If we do cluster analysis we may use
% 'cityblock' distances, the first Laplacian
% norm)

function D = distL2(A, B)
    % Gather dimensionality
    [N_A, ~] = size(A);
    [N_B, ~] = size(B);
    if(N_A > 1)
        disp('The first argument must be only one value');
        return;
    end

    % Calculate Distance
    D = sqrt(sum(power(repmat(A,N_B,1) - B,2),2));
end