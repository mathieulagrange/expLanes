function [f,p,r] = pairWiseMatching(target, prediction)

if nargin==0
    prediction=[1 1 3 3 4 4 5 5 6 6 5 5];
    target    =[2 2 1 1 2 2 1 1 2 2 1 1];
    [f,p,r] = pairWiseMatching(target, prediction);
    disp(['F=' num2str(f) '; P=' num2str(p) '; R=' num2str(r)]);
    return;
end

%% Metric Computation
Pa=abs(pdist(target(:),'hamming')-1);
Pe=abs(pdist(prediction(:),'hamming')*2-2);
P=Pe-Pa;
%  P=triu(P,1);
%  Pe=triu(Pe,1);
%  Pa=triu(Pa,1);


Mea=length(find(P==1));
Me=length(find(Pe==2));
Ma=length(find(Pa==1));

if(Me==0)
    warning('trivial case, no pair in prediction');
    p=0;
else
    p=Mea/Me;
end
if(Ma==0)
    warning('trivial case, no pair in target');
    r=0;
else
    r=Mea/Ma;
end
if p+r == 0
    f=0;
else
    f=2*p*r/(p+r);
end