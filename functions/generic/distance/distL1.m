%% Distance (First Laplacian Norm)

% This function returns the first Laplacian
% norm of two vectors, this norm is commonly
% referred to as the Cityblock distance. It is
% the sum of the squares of the distances on
% each dimension. If the second vector is a
% matrix it will return a vector of all of the
% distances from each row vectors in this
% matrix to the first.

% Author: A. Conrad Nied, 2011.09.20
 
%% Inputs
% vector A, vector OR matrix B

%% Outputs
% distance from A to B
% OR
% array of distances from A to vectors in B.

%% Example:
% distL1([1 0],[3 0; 4 4; 2 1]) = [2; 7; 2]

function D = distL1(A, B)
    % Gather dimensionality
    [N_A, ~] = size(A);
    [N_B, ~] = size(B);
    if(N_A > 1)
        disp('The first argument must be only one value');
        return;
    end

    % Calculate Distance
    D = sum(abs(repmat(A,N_B,1) - B),2);
end