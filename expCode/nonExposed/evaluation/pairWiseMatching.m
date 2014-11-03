function [f,p,r] = pairWiseMatching(target, prediction)

if (nargin==0)
%     prediction=[1 2 1 2];
%     target=[1 1 1 1];
    prediction=[1 1 1 1];
    target=[1 2 3 4];
    [f,p,r] = pairWiseMatching(target, prediction)
end

%% Metric Computation
 Pa=squareform(pdist(target(:)));
 Pa(Pa~=0)=1;
 Pa=abs(Pa-1);
 Pe=squareform(pdist(prediction(:)));
 Pe(Pe~=0)=2;
 Pe=abs(Pe-2);
 P=Pe-Pa;
 P=triu(P,1);
 Pe=triu(Pe,1);
 Pa=triu(Pa,1);
 
 
 Mea=length(find(P==1));
 Me=length(find(Pe==2));
 Ma=length(find(Pa==1));
 
 if(Me==0) % trivial case, no pair in prediction (=> Mea=0)
     p=1; 
 else
    p=Mea/Me;
 end
 if(Ma==0) % trivial case no pair in target (=> Mea=0)
     r=1;
 else
    r=Mea/Ma;
 end
 f=2*p*r/(p+r);
 