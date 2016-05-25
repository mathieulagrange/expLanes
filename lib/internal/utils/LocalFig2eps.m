function LocalFig2eps(varargin)

if(nargin==1)
    
    file_name=varargin{1};
    h=gcf;
    
    
elseif nargin==2  
    h=varargin{1};
    file_name=varargin{2};
else
    error('Arg error');
end

%     resolution=get(0,'ScreenPixelsPerInch');

saveas(h, [file_name '.fig'], 'fig');
      
set(h,'Units','centimeters');
set(h,'PaperUnits','centimeters');

Position=get(h,'Position');


Lx=Position(3);
Ly=Position(4);



set(h,'PaperSize',[Lx Ly]);
set(h,'PaperPosition',[0 0 Lx Ly]);



print( h, '-dpdf', file_name )
print( h, '-dpng', strrep(file_name, '.pdf', '.png'))


set(h,'Units','points');

PosPoint=get(h,'Position');
set(h,'Units','centimeters');
PosPoint(1:2)=0;

%     FastEPSResize(file_name,PosPoint);



end