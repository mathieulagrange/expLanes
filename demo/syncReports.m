
r=dir('*pdf');

for k=1:length(r)
   [~, n] = fileparts(r(k).name);
   copyfile([n '/report/' n '.pdf'], '.'); 
end