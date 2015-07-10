function expRandomSeed()
% expRandomSeed ensure replicability
%	expRandomSeed() ensure replicability by setting the seed 
%       of the random generator to the same value in order

%	Copyright (c) 2014 Mathieu Lagrange (mathieu.lagrange@cnrs.fr)
%	See licence.txt for more information.


rng(0, 'twister');