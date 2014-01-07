function demprior(action);
%DEMPRIOR Demonstrate sampling from a multi-parameter Gaussian prior.
%
%	Description
%	This function plots the functions represented by a multi-layer
%	perceptron network when the weights are set to values drawn from a
%	Gaussian prior distribution. The parameters AW1, AB1 AW2 and AB2
%	control the inverse variances of the first-layer weights, the hidden
%	unit  biases, the second-layer weights and the output unit biases
%	respectively.  Their values can be adjusted on a logarithmic scale
%	using the sliders, or  by typing values into the text boxes and
%	pressing the return key.
%
%	See also
%	MLP
%

%	Copyright (c) Ian T Nabney (1996-2001)

if nargin<1,
    action='initialize';
end;

if strcmp(action,'initialize')
  
  aw1 = 0.01;
  ab1 = 0.1;
  aw2 = 1.0;
  ab2 = 1.0;
  
  % Create FIGURE
  fig=figure( ...
    'Name','Sampling from a Gaussian prior', ...
    'Position', [50 50 480 380], ...
    'NumberTitle','off', ...
    'Color', [0.8 0.8 0.8], ...
    'Visible','on');

  % The TITLE BAR frame
  uicontrol(fig,  ...
    'Style','frame', ...
    'Units','normalized', ...
    'HorizontalAlignment', 'center', ...
    'Position', [0.5 0.82 0.45 0.1], ...
    'BackgroundColor',[0.60 0.60 0.60]);
  
  % The TITLE BAR text
  uicontrol(fig, ...
    'Style', 'text', ...
    'Units', 'normalized', ...
    'BackgroundColor', [0.6 0.6 0.6], ...
    'Position', [0.54 0.85 0.40 0.05], ...
    'HorizontalAlignment', 'left', ...
    'String', 'Sampling from a Gaussian prior');
  
  % Frames to enclose sliders
  uicontrol(fig, ...
    'Style', 'frame', ...
    'Units', 'normalized', ...
    'BackgroundColor', [0.6 0.6 0.6], ...
    'Position', [0.05 0.08 0.35 0.18]);
  
  uicontrol(fig, ...
    'Style', 'frame', ...
    'Units', 'normalized', ...
    'BackgroundColor', [0.6 0.6 0.6], ...
    'Position', [0.05 0.3 0.35 0.18]);
   
  uicontrol(fig, ...
    'Style', 'frame', ...
    'Units', 'normalized', ...
    'BackgroundColor', [0.6 0.6 0.6], ...
    'Position', [0.05 0.52 0.35 0.18]);
   
  uicontrol(fig, ...
    'Style', 'frame', ...
    'Units', 'normalized', ...
    'BackgroundColor', [0.6 0.6 0.6], ...
    'Position', [0.05 0.74 0.35 0.18]);
   
  % Frame text
  uicontrol(fig, ...
    'Style', 'text', ...
    'Units', 'normalized', ...
    'HorizontalAlignment', 'left', ...
    'BackgroundColor', [0.6 0.6 0.6], ...
    'Position', [0.07 0.17 0.06 0.07], ...
    'String', 'aw1');

  % Frame text
  uicontrol(fig, ...
    'Style', 'text', ...
    'Units', 'normalized', ...
    'HorizontalAlignment', 'left', ...
    'BackgroundColor', [0.6 0.6 0.6], ...
    'Position', [0.07 0.39 0.06 0.07], ...
    'String', 'ab1');

  % Frame text
  uicontrol(fig, ...
    'Style', 'text', ...
    'Units', 'normalized', ...
    'HorizontalAlignment', 'left', ...
    'BackgroundColor', [0.6 0.6 0.6], ...
    'Position', [0.07 0.61 0.06 0.07], ...
    'String', 'aw2');

  % Frame text
  uicontrol(fig, ...
    'Style', 'text', ...
    'Units', 'normalized', ...
    'HorizontalAlignment', 'left', ...
    'BackgroundColor', [0.6 0.6 0.6], ...
    'Position', [0.07 0.83 0.06 0.07], ...
    'String', 'ab2');
   
  % Slider
  minval = -5; maxval = 5;
  aw1slide = uicontrol(fig, ...
    'Style', 'slider', ...
    'Units', 'normalized', ...
    'Value', log10(aw1), ...
    'BackgroundColor', [0.8 0.8 0.8], ...
    'Position', [0.07 0.1 0.31 0.05], ...
    'Min', minval, 'Max', maxval, ...
    'Callback', 'demprior update');
  
  % Slider
  ab1slide = uicontrol(fig, ...
    'Style', 'slider', ...
    'Units', 'normalized', ...
    'Value', log10(ab1), ...
    'BackgroundColor', [0.8 0.8 0.8], ...
    'Position', [0.07 0.32 0.31 0.05], ...
    'Min', minval, 'Max', maxval, ...
    'Callback', 'demprior update');
  
  % Slider
  aw2slide = uicontrol(fig, ...
    'Style', 'slider', ...
    'Units', 'normalized', ...
    'Value', log10(aw2), ...
    'BackgroundColor', [0.8 0.8 0.8], ...
    'Position', [0.07 0.54 0.31 0.05], ...
    'Min', minval, 'Max', maxval, ...
    'Callback', 'demprior update');
  
  % Slider
  ab2slide = uicontrol(fig, ...
    'Style', 'slider', ...
    'Units', 'normalized', ...
    'Value', log10(ab2), ...
    'BackgroundColor', [0.8 0.8 0.8], ...
    'Position', [0.07 0.76 0.31 0.05], ...
    'Min', minval, 'Max', maxval, ...
    'Callback', 'demprior update');
  
  % The graph box
  haxes = axes('Position', [0.5 0.28 0.45 0.45], ...
    'Units', 'normalized', ...
    'Visible', 'on');
  
  % Text obs of hyper-parameter values
  
  format = '%8f';
  
  aw1val = uicontrol(fig, ...
    'Style', 'edit', ...
    'Units', 'normalized', ...
    'Position', [0.15 0.17 0.23 0.07], ...
    'String', sprintf(format, aw1), ...
    'Callback', 'demprior newval');
  
  ab1val = uicontrol(fig, ...
    'Style', 'edit', ...
    'Units', 'normalized', ...
    'Position', [0.15 0.39 0.23 0.07], ...
    'String', sprintf(format, ab1), ...
    'Callback', 'demprior newval');
  
  aw2val = uicontrol(fig, ...
    'Style', 'edit', ...
    'Units', 'normalized', ...
    'Position', [0.15 0.61 0.23 0.07], ...
    'String', sprintf(format, aw2), ...
    'Callback', 'demprior newval');
  
  ab2val = uicontrol(fig, ...
    'Style', 'edit', ...
    'Units', 'normalized', ...
    'Position', [0.15 0.83 0.23 0.07], ...
    'String', sprintf(format, ab2), ...
    'Callback', 'demprior newval');
   
  % The SAMPLE button
  uicontrol(fig, ...
    'Style','push', ...
    'Units','normalized', ...
    'BackgroundColor', [0.6 0.6 0.6], ...
    'Position',[0.5 0.08 0.13 0.1], ...
    'String','Sample', ...
    'Callback','demprior replot');
  
  % The CLOSE button
  uicontrol(fig, ...
    'Style','push', ...
    'Units','normalized', ...
    'BackgroundColor', [0.6 0.6 0.6], ...
    'Position',[0.82 0.08 0.13 0.1], ...
    'String','Close', ...
    'Callback','close(gcf)');
  
  % The HELP button
  uicontrol(fig, ...
    'Style','push', ...
    'Units','normalized', ...
    'BackgroundColor', [0.6 0.6 0.6], ...
    'Position',[0.66 0.08 0.13 0.1], ...
    'String','Help', ...
    'Callback','demprior help');
  
   % Save handles to objects
  
  hndlList=[fig aw1slide ab1slide aw2slide ab2slide aw1val ab1val aw2val ...
      ab2val haxes];
  set(fig, 'UserData', hndlList);
  
  demprior('replot')
  
  
elseif strcmp(action, 'update'),
  
  % Update when a slider is moved.
  
  hndlList   = get(gcf, 'UserData');
  aw1slide   = hndlList(2);
  ab1slide = hndlList(3);
  aw2slide  = hndlList(4);
  ab2slide = hndlList(5);
  aw1val = hndlList(6);
  ab1val = hndlList(7);
  aw2val = hndlList(8);
  ab2val = hndlList(9);
  haxes = hndlList(10);
  
  aw1 = 10^get(aw1slide, 'Value');
  ab1 = 10^get(ab1slide, 'Value');
  aw2 = 10^get(aw2slide, 'Value');
  ab2 = 10^get(ab2slide, 'Value');
    
  format = '%8f';
  set(aw1val, 'String', sprintf(format, aw1));
  set(ab1val, 'String', sprintf(format, ab1));
  set(aw2val, 'String', sprintf(format, aw2));
  set(ab2val, 'String', sprintf(format, ab2));
  
  demprior('replot');
  
elseif strcmp(action, 'newval'),
  
  % Update when text is changed.
  
  hndlList   = get(gcf, 'UserData');
  aw1slide   = hndlList(2);
  ab1slide = hndlList(3);
  aw2slide  = hndlList(4);
  ab2slide = hndlList(5);
  aw1val = hndlList(6);
  ab1val = hndlList(7);
  aw2val = hndlList(8);
  ab2val = hndlList(9);
  haxes = hndlList(10);
    
  aw1 = sscanf(get(aw1val, 'String'), '%f');
  ab1 = sscanf(get(ab1val, 'String'), '%f');
  aw2 = sscanf(get(aw2val, 'String'), '%f');
  ab2 = sscanf(get(ab2val, 'String'), '%f');
  
  set(aw1slide, 'Value', log10(aw1));
  set(ab1slide, 'Value', log10(ab1));
  set(aw2slide, 'Value', log10(aw2));
  set(ab2slide, 'Value', log10(ab2));
  
  demprior('replot');
  
elseif strcmp(action, 'replot'),
  
  % Re-sample from the prior and plot graphs.
 
  oldFigNumber=watchon;

  hndlList   = get(gcf, 'UserData');
  aw1slide   = hndlList(2);
  ab1slide = hndlList(3);
  aw2slide  = hndlList(4);
  ab2slide = hndlList(5);
  haxes = hndlList(10);
  
  aw1 = 10^get(aw1slide, 'Value');
  ab1 = 10^get(ab1slide, 'Value');
  aw2 = 10^get(aw2slide, 'Value');
  ab2 = 10^get(ab2slide, 'Value');
 
  axes(haxes);
  cla
  set(gca, ...
    'Box', 'on', ...
    'Color', [0 0 0], ...
    'XColor', [0 0 0], ...
    'YColor', [0 0 0], ...
    'FontSize', 14);
  axis([-1 1 -10 10]);  
  set(gca,'DefaultLineLineWidth', 2);

  nhidden = 12;
  prior = mlpprior(1, nhidden, 1, aw1, ab1, aw2, ab2);
  xvals = -1:0.005:1;
  nsample = 10;    % Number of samples from prior.
  hold on
  plot([-1 0; 1 0], [0 -10; 0 10], 'b--');
  net = mlp(1, nhidden, 1, 'linear', prior);
  for i = 1:nsample
    net = mlpinit(net, prior);
    yvals = mlpfwd(net, xvals');
    plot(xvals', yvals, 'y');
  end
    
  watchoff(oldFigNumber);
 
elseif strcmp(action, 'help'),
  
  % Provide help to user.

  oldFigNumber=watchon;

  helpfig = figure('Position', [100 100 480 400], ...
    'Name', 'Help', ...
    'NumberTitle', 'off', ...
    'Color', [0.8 0.8 0.8], ...
    'Visible','on');
  
    % The HELP TITLE BAR frame
  uicontrol(helpfig,  ...
    'Style','frame', ...
    'Units','normalized', ...
    'HorizontalAlignment', 'center', ...
    'Position', [0.05 0.82 0.9 0.1], ...
    'BackgroundColor',[0.60 0.60 0.60]);
  
  % The HELP TITLE BAR text
  uicontrol(helpfig, ...
    'Style', 'text', ...
    'Units', 'normalized', ...
    'BackgroundColor', [0.6 0.6 0.6], ...
    'Position', [0.26 0.85 0.6 0.05], ...
    'HorizontalAlignment', 'left', ...
    'String', 'Help: Sampling from a Gaussian Prior');
  
  helpstr1 = strcat( ...
    'This demonstration shows the effects of sampling from a Gaussian', ...
     ' prior over weights for a two-layer feed-forward network. The', ...
     ' parameters aw1, ab1, aw2 and ab2 control the inverse variances of', ...
     ' the first-layer weights, the hidden unit biases, the second-layer', ...
     ' weights and the output unit biases respectively. Their values can', ...
     ' be adjusted on a logarithmic scale using the sliders, or by', ...
     ' typing values into the text boxes and pressing the return key.', ...
     '  After setting these values, press the ''Sample'' button to see a', ...
     ' new sample from the prior. ');
   helpstr2 = strcat( ...
     'Observe how aw1 controls the horizontal length-scale of the', ...
     ' variation in the functions, ab1 controls the input range over', ...
     ' such variations occur, aw2 sets the vertical scale of the output', ...
     ' and ab2 sets the vertical off-set of the output. The network has', ...
     ' 12 hidden units. ');
   hstr(1) = {helpstr1};
   hstr(2) = {''};
   hstr(3) = {helpstr2};

  % The HELP text
  helpui = uicontrol(helpfig, ...
    'Style', 'edit', ...
    'Units', 'normalized', ...
    'ForegroundColor', [0 0 0], ...
    'HorizontalAlignment', 'left', ...
    'BackgroundColor', [1 1 1], ...
    'Min', 0, ...
    'Max', 2, ...
    'Position', [0.05 0.2 0.9 0.8]);
   
   [hstrw , newpos] = textwrap(helpui, hstr, 70);
   set(helpui, 'String', hstrw, 'Position', [0.05, 0.2, 0.9, newpos(4)]);
   
   
  % The CLOSE button
  uicontrol(helpfig, ...
    'Style','push', ...
    'Units','normalized', ...
    'BackgroundColor', [0.6 0.6 0.6], ...
    'Position',[0.4 0.05 0.2 0.1], ...
    'String','Close', ...
    'Callback','close(gcf)');

   watchoff(oldFigNumber);

end;

