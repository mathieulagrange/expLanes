function [label, energy, it, t,Z, e] = knkmeans(K,m, nbIterations, factor)
%% Written by Mo Chen (mochen@ie.cuhk.edu.hk). March 2009.
% K: kernel matrix
% m: k (1 x 1) or label (1 x n, 1<=label(i)<=k)
% reference: [1] Kernel Methods for Pattern Analysis
% by John Shawe-Taylor, Nello Cristianini

if nargin<3, nbIterations=500; end
if nargin<4, factor=0; end

n = size(K,1);
if max(size(m)) == 1
    k = m;
    %     label = randi(k,1,n);
    label = ceil(k*rand(1,n));
elseif size(m,1) == 1 && size(m,2) == n
    k = max(m);
    label = m;
else
    error('ERROR: m is not valid.');
end
%% version 1: directly implement the formula in [1]
last = 0;
it=0;
S = repmat((1:k)',1,n);
t=[];
e=[];
while any(label ~= last) && it<nbIterations
%     disp(['iteration ' num2str(it)])
    %     E = sparse(label,1:n,1,k,n,n);
    %     E = spdiags(sum(E,2),0,k,k)*E;
    E = double(bsxfun(@eq,S,label));
    E = bsxfun(@rdivide,E,sum(E,2));
    T = E*K;
    if factor==1
        Z = -2*T;
    elseif factor==2
        Z = repmat(diag(T*E'),1,n);
    else
        Z = repmat(diag(T*E'),1,n)-2*T;  
    end
    
    last = label;
    [val, label] = min(Z,[],1);
    SS = repmat(diag(T*E'),1,n);
    t(end+1, 1) = sum(T(label));
    t(end, 2) = sum(SS(label));
    t(end, 3) = (sum(val)+trace(K))/max(K(:));
    it=it+1;

    energy= sum(val)+trace(K);
e(end+1) = energy/max(K(:));
end
energy = sum(val)+trace(K);
energy = energy/max(K(:));

% plot(diff(t));
% legend({'1', '2', 'all'});

% if it>=nbIterations, disp('knkmeans did not converged'); end

%% version 2 is equivalent to version 1 but without matrix multiplication
% Z = zeros(k,n);
% diff = true;
% while diff
%     for i = 1:k
%         idx = label==i; nc = sum(idx);
%         T = K(idx,idx);
%         Z(i,:) = sum(T(:))/(nc*nc)-2*sum(K(idx,:))/nc;
%     end
%     last_label = label;
%     [val, label] = min(Z);
%     diff = any(label~=last_label);
% end
% energy = sum(val)+trace(K);