
r=dir('*pdf');

for k=1:length(r)
   [~, n] = fileparts(r(1).name);
   copyfile([n '/report/' n '.pdf'], '.'); 
end