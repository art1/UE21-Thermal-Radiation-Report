function hpol = dirplot(theta,rho,line_style,params)
% DIRPLOT  Polar directivity plot.
%   A modification of The Mathworks POLAR function, DIRPLOT generates
%   directivity plots in the style commonly used in acoustic and RF work.
%   Features include:
%     1. Plots -90 to +90 or -180 to +180 degrees based on range of input
%        THETA, with 0 degrees at top center.
%     2. Produces semicircular plots when plot range is -90 to +90 degrees.
%     3. RHO is assumed to be in decibels and may include negative
%        values.
%     4. Default automatic rho-axis scaling in "scope knob" factors.
%     5. Optional PARAMS argument allows manual setting of rho-axis
%        scaling.
%   
%   DIRPLOT(THETA, RHO) makes a plot using polar coordinates of the
%   angle THETA versus the radius RHO. THETA must be in degrees, and
%   must be within the range -180 to +180 degrees. If THETA is within
%   the range -90 to +90 degrees, the plot will be semicircular. RHO is
%   assumed to be in decibels and the values may be positive or negative or
%   both. By default, with no PARAMS argument, rho-axis scaling will be determined
%   automatically using scope knob factors of 1-2-5. By default, 10
%   ticks will be plotted. Note: Like POLAR, DIRPLOT does not rescale the
%   axes when a new plot is added to a held graph.
%
%   DIRPLOT(THETA, RHO, LINE_STYLE, PARAMS) makes a plot as described above
%   using the linestyle specified in string LINE_STYLE, and using the rho-axis
%   scaling specified in vector PARAMS. Either of these optional arguments may be
%   used alone. Vector PARAMS is a 3-element row vector defined as
%   [RHOMAX RHOMIN RHOTICKS]. String LINE_STYLE is the standard MATLAB linestyle
%   string. See PLOT for a description.
%
%   HPOL = DIRPLOT(...) returns a handle to the LINE object generated by the PLOT
%   function that actually generates the plot in DIRPLOT.
% 
%   See also POLAR, PLOT, LOGLOG, SEMILOGX, SEMILOGY.
% 
%   Tested in MATLAB v. 6.0 (R12)
%
%   Revision History
%       18 January 2014: Fixed a bug that caused RHO to be plotted incorrectly if 
%           RHOMIN was specified, and RHO was less than RHOMIN. Thanks to Wajih Elsallal.
%       11 June 2012: Changed contact email address only
%       18 January 2002: Original posting
%
%   Adapted from The MathWorks POLAR function by
%   Steve Rickman
%   sxrickman@gmail.com

if nargin <= 1
    error('Requires 2, 3, or 4 input arguments.')
elseif nargin == 2
    line_style = 'auto';
elseif nargin == 3 
    if isnumeric(line_style)
        params = line_style;
        line_style = 'auto';
    end
end
if exist('params')
    if length(params) ~= 3
        error('Argument PARAMS must be a 3-element vector: [RHOMAX RHOMIN RHOTICKS].')
    end
    if params(1) <= params(2)
        error('Error in PARAMS argument. RHOMAX must be greater than RHOMIN.')
    end
    if params(3) <= 0
        params(3) = 1;
        warning('Error in PARAMS argument. RTICKS set to 1.')
    end
end
if isstr(theta) | isstr(rho)
    error('THETA and RHO must be numeric.');
end
if ~isequal(size(theta),size(rho))
    error('THETA and RHO must be the same size.');
end
if (max(theta) - min(theta)) < 6.3
    warning('THETA must be in degrees');
end
if min(theta) >= 0
    warning('Plot is -90 to +90 or -180 to +180 degrees');
end
if max(abs(theta)) > 180
    error('Plot is -90 to +90 or -180 to +180 degrees');
end

% Get range of theta and set flag for full or half plot.
if (max(theta)-min(theta)) > 180 | max(theta) > 90
    fullplot = 1;
else
    fullplot = 0;
end

% Translate theta degrees to radians
theta = theta*pi/180;

cax = newplot;
next = lower(get(cax,'NextPlot'));
hold_state = ishold;

if hold_state & exist('params')
    warning('Plot is held. New plot parameters ignored')
end

% get x-axis text color so grid is in same color
tc = get(cax,'xcolor');
ls = get(cax,'gridlinestyle');

% Hold on to current Text defaults, reset them to the
% Axes' font attributes so tick marks use them.
fAngle  = get(cax, 'DefaultTextFontAngle');
fName   = get(cax, 'DefaultTextFontName');
fSize   = get(cax, 'DefaultTextFontSize');
fWeight = get(cax, 'DefaultTextFontWeight');
fUnits  = get(cax, 'DefaultTextUnits');
set(cax, 'DefaultTextFontAngle',  get(cax, 'FontAngle'), ...
    'DefaultTextFontName',   get(cax, 'FontName'), ...
    'DefaultTextFontSize',   get(cax, 'FontSize'), ...
    'DefaultTextFontWeight', get(cax, 'FontWeight'), ...
    'DefaultTextUnits','data')

% only do grids if hold is off
if ~hold_state    
    % make a radial grid
    hold on;
    if ~exist('params')
        rticks = 10; % default ticks
        lims = findscale(rho,rticks); % get click, rmax, rmin
        click = lims(1); rmax = lims(2); rmin = lims(3);
        rngdisp = rmax - rmin;
    else
        rmax = params(1); rmin = params(2); rticks = params(3);
        rngdisp = rmax - rmin;
        click = rngdisp/rticks;
        % clip the data where RHO<rmin (bug fix Jan 2014)
        [m,n] = find(rho<rmin);   
        rho(m,n) = rmin;
    end
   
    set(cax,'userdata',[rngdisp rmax rmin]); % save variables for added plots
 
    % define a circle
    th = 0:pi/50:2*pi;
    xunit = cos(th);
    yunit = sin(th);
    % now really force points on x/y axes to lie on them exactly
    inds = 1:(length(th)-1)/4:length(th);
    xunit(inds(2:2:4)) = zeros(2,1);
    yunit(inds(1:2:5)) = zeros(3,1);
    % plot background if necessary
    if ~isstr(get(cax,'color')),
        patch('xdata',xunit*rngdisp,'ydata',yunit*rngdisp, ...
            'edgecolor',tc,'facecolor',get(gca,'color'),...
            'handlevisibility','off');
    end
    
    % draw radial circles
    % angles for text labels
    c88 = cos(88*pi/180);
    s88 = sin(88*pi/180);
    c92 = -cos(92*pi/180);
    s92 = -sin(92*pi/180);
    
    for i=click:click:rngdisp
        tickt = i+rmin;
        if abs(tickt) < .001
            tickt = 0;
        end
        ticktext = ['' num2str(tickt)];
        hhh = plot(xunit*i,yunit*i,ls,'color',tc,'linewidth',1,...
            'handlevisibility','off');
        if i < rngdisp
            text(i*c88,i*s88, ...
                ticktext,'verticalalignment','bottom',...
                'handlevisibility','off','fontsize',8)
        else
            text(i*c88,i*s88, ...
                [ticktext,' dB'],'verticalalignment','bottom',...
                'handlevisibility','off','fontsize',8)
        end
        if fullplot
            if i < rngdisp
                text(i*c92,i*s92, ...
                    ticktext,'verticalalignment','bottom',...
                    'handlevisibility','off','fontsize',8)
            else
                text(i*c92,i*s92, ...
                    [ticktext,' dB'],'verticalalignment','bottom',...
                    'handlevisibility','off','fontsize',8)
            end            
        end
    end
    set(hhh,'linestyle','-') % Make outer circle solid
    
    % plot spokes at 10 degree intervals
    th = (0:18)*2*pi/36;
    
    cst = cos(th); snt = sin(th);
    cs = [-cst; cst];
    sn = [-snt; snt];
    plot(rngdisp*cs,rngdisp*sn,ls,'color',tc,'linewidth',1,...
        'handlevisibility','off')
    
    % label spokes in 30 degree intervals
    rt = 1.1*rngdisp;
    for i = 1:3:19
        text(rt*cst(i),rt*snt(i),[int2str(90-(i-1)*10),'^o'],...
            'horizontalalignment','center',...
            'handlevisibility','off'); 
    end
    if fullplot
        for i = 3:3:6
            text(-rt*cst(i+1),-rt*snt(i+1),[int2str(-90-i*10),'^o'],...
                'horizontalalignment','center',...
                'handlevisibility','off'); 
        end
        for i = 9:3:15
            text(-rt*cst(i+1),-rt*snt(i+1),[int2str(270-i*10),'^o'],...
                'horizontalalignment','center',...
                'handlevisibility','off'); 
        end        
    end
    
    % set view to 2-D
    view(2);
    % set axis limits
    if fullplot
        axis(rngdisp*[-1 1 -1.15 1.15]);
    else
        axis(rngdisp*[-1 1 0 1.15]);        
    end
end

if hold_state
    v = get(cax,'userdata');
    rngdisp = v(1);
    rmax = v(2);
    rmin = v(3);
end
        
% Reset defaults.
set(cax, 'DefaultTextFontAngle', fAngle , ...
    'DefaultTextFontName',   fName , ...
    'DefaultTextFontSize',   fSize, ...
    'DefaultTextFontWeight', fWeight, ...
    'DefaultTextUnits',fUnits );

% transform data to Cartesian coordinates.
% Rotate by pi/2 to get 0 degrees at top. Use negative
% theta to have negative degrees on left.
xx = (rho+rngdisp-rmax).*cos(-theta+pi/2);
yy = (rho+rngdisp-rmax).*sin(-theta+pi/2);

% plot data on top of grid
if strcmp(line_style,'auto')
    q = plot(xx,yy);
else
    q = plot(xx,yy,line_style);
end
if nargout > 0
    hpol = q;
end
set(gca,'dataaspectratio',[1 1 1]), axis off; set(cax,'NextPlot',next);
set(get(gca,'xlabel'),'visible','on')
set(get(gca,'ylabel'),'visible','on')

% Subfunction finds optimal scaling using "scope knob"
% factors of 1, 2, 5. Range is limited to practical
% decibel values.
function lims = findscale(rho, rticks)
	clicks = [.001 .002 .005 .01 .02 .05 .1 ...
              .2 .5 1 2 5 10 20 50 100 200 500 1000];
	lenclicks = length(clicks);
	rhi = max(rho);
	rlo = min(rho);
	rrng = rhi - rlo;
	rawclick = rrng/rticks;
	n = 1;
	while clicks(n) < rawclick
        n = n + 1;
        if n > lenclicks
            close;
            error('Cannot autoscale; unrealistic decibel range.');
        end
	end
	click = clicks(n);
	
	m = floor(rhi/click);
	rmax = click * m;
	if rhi - rmax ~= 0
        rmax = rmax + click;
	end	
	rmin = rmax - click * rticks;
	
	% Check that minimum rho value is at least one tick
	% above rmin. If not, increase click value and
	% rescale.
    if rlo < rmin + click
        if n < lenclicks
            click = clicks(n+1);
        else
            error('Cannot autoscale; unrealistic decibel range.');
        end
        
        m = floor(rhi/click);
        rmax = click * m;
        if rhi - rmax ~= 0
            rmax = rmax + click;
        end
        rmin = rmax - click * rticks;
    end
    lims = [click rmax rmin];
    