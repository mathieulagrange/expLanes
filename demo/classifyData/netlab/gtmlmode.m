function settings = gtmlsetting(net, data)
%GTMLMODE Setting responsibility for data in a GTM.
%
%	Description
%	 MODES = GTMLMODE(NET, DATA) takes a GTM structure NET, and computes
%	the settings of the responsibility  distributions for each data point in
%	DATA.  These will always lie at one of the latent space sample points
%	NET.X.
%
%	See also
%	GTM, GTMPOST, GTMLMEAN
%

%	Copyright (c) Ian T Nabney (1996-2001)

% Check for consistency
errstring = consist(net, 'gtm', data);
if ~isempty(errstring)
  error(errstring);
end

R = gtmpost(net, data);
% Setting is maximum responsibility
[max_resp, max_index] = max(R, [], 2);
settings = net.X(max_index, :);
