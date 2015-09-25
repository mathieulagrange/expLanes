function config = brgeshReport(config)                                  
% brgeshReport REPORTING of the expLanes experiment branchGeometricShape
%    config = brgeshInitReport(config)                                  
%       config : expLanes configuration state                           
                                                                        
% Copyright: Mathieu Lagrange                                           
% Date: 25-Sep-2015                                                     
                                                                        
if nargin==0, branchGeometricShape('report', 'r'); return; end          
                                                                        
config = expExpose(config, 't');                                        
