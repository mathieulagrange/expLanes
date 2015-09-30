function expSaveFig(fileName, h)

if nargin<2, h=gcf; end

set(h,'Units','centimeters');
set(h,'PaperUnits','centimeters');

Position=get(h,'Position');

Lx=Position(3);
Ly=Position(4);

set(h,'PaperSize',[Lx Ly]);
set(h,'PaperPosition',[0 0 Lx Ly]);

print(h, '-dpdf', [fileName '.pdf']);
print(h, '-dpng', [fileName '.png']);
print(h, '-deps', [fileName '.eps']);
hgsave(h, [fileName '.fig']);
