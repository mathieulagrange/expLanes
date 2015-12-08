
r=dir('*pdf');

for k=1:length(r)
   [~, n] = fileparts(r(k).name);
   copyfile([n '/report/' n '.pdf'], '.'); 
   system(['convert -density 300 ' n '/report/figures/factors.pdf -quality 90 ' n '/report/figures/factors.png']);
end