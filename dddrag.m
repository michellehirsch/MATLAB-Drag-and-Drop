function dddrag
%dddrag     Implement the dragging functionality of dragndrop interface
% Copyright 2003 The MathWorks, Inc

source = gcbo;
hFig = get(source,'Parent');    %This restricts the application to uicontrols and axes
%Check the parent.  If it's an axes, not a figure, we do a little
%manipulation.  This allows you to drag an axes by grabbing one of it's
%lines.
if strcmp(get(hFig,'Type'),'axes')
    source = hFig;              %Assign the parent axes to source
    hFig = get(hFig,'Parent');
end;


%% Let user drag ...
%dragrect works with rect specified in pixels.  Odd, since it returns
%values in the host figure's units.
un = get(source ,'Units');
set(source,'Units','pixels');
rect = [get(source,'Position')];
finalrect = dragrect(rect); %#ok<NASGU>
set(source,'Units',un);

%For testing only - move the block to the drop location
%set(gcbo,'Position',finalrect(1,:));        %Main button

%% Figure out where we landed
% current_object = hittest;   % Tells us what object we were over when letting go
current_objects = undermouse(hFig); % Get the object(s) under the mouse

% Replace any axes children with their parents since we don't track
% axes children as drop targets
parents = get(current_objects,'Parent');
if iscell(parents)
    parents = vertcat(parents{:});
end

axkids = strcmp(get(parents,'Type'),'axes');
current_objects(axkids) = parents(axkids);

%% Are any of the current objects in our hit list?

% Get the dragndrop object from the figure
dd = getappdata(hFig,'dragndrop');          %Get object
Drops = get(dd,'DropHandles');              % Handles to drop targets

% What did we hit?
hit_ind = find(ismember(Drops, current_objects));    % Index into drop target we hit

%% Did we hit a drop target? If not, exit
if isempty(hit_ind)
    notvalid    % Indicate to user that this wasn't valid.
    return
end;

% Is our drop target valid for this source?
DropValidDrag = get(dd,'DropValidDrag');
validdrag = [DropValidDrag{hit_ind}];         % Valid drag sources for this target

if ~ismember(source,validdrag)
    notvalid
    return
end;

%% Evaluate callback
% Did we hit multiple targets? If so, only fire callback for first one
if length(hit_ind) > 1
    hit_ind = hit_ind(1);
end

DropCallbacks = get(dd,'DropCallbacks');
feval(DropCallbacks{hit_ind},source,Drops(hit_ind));

function obj = undermouse(hFig)
kids = get(hFig,'Children');

% Remove menus, so that everything else works nicely.
menus = [ findobj(hFig,'Type','uimenu')
    findobj(hFig,'Type','uicontextmenu')];
kids = setdiff(kids,menus);


% remove uicontextmenu

% Get object positions, in current figure units
units = get(kids,'Units');
set(kids,'Units',get(gcf,'Units'))
positions = cell2mat(get(kids,'Position'));
set(kids,{'Units'},units)      % Put things back the way they were


xlimits = [positions(:,1) positions(:,1)+positions(:,3)];
ylimits = [positions(:,2) positions(:,2)+positions(:,4)];

% If I didn't mind restricting this to 13b or newer, I'd use a table to
% keep limits and kids all together. It would be lovely.

cp = get(hFig,'CurrentPoint');

inx = xlimits(:,1)<=cp(1) & cp(1) <= xlimits(:,2);
iny = ylimits(:,1)<=cp(2) & cp(2) <= ylimits(:,2);

in = find(inx & iny);

if isempty(in) % Didn't find anything - it looks like we are over the figure
    obj = hFig;
else
    % Return all of the objects underneath the mouse
    obj = kids(in);
    
end





function notvalid
% Indicate to the user that the source can't be dropped here.
ptr = get(gcf,'Pointer');
P = no_icon;
set(gcf,'Pointer','custom');
set(gcf,'PointerShapeCData',P,'PointerShapeHotSpot',[9 9]);
pause(.2)
set(gcf,'Pointer',ptr);


function P = no_icon
% Create icon for mouse pointer indicating target isn't valid
P=[ NaN     NaN     NaN     NaN     NaN     NaN     NaN     NaN     NaN     NaN     NaN     NaN     NaN     NaN     NaN     NaN
    NaN     NaN     NaN     NaN     NaN     NaN     NaN     NaN     NaN     NaN     NaN     NaN     NaN     NaN     NaN     NaN
    NaN     NaN     NaN     NaN     NaN     NaN     NaN     NaN     NaN     NaN     NaN     NaN     NaN     NaN     NaN     NaN
    NaN     NaN     NaN     NaN     NaN     NaN     NaN     1     1     NaN     NaN     NaN     1     NaN     NaN     NaN
    NaN     NaN     NaN     NaN     NaN     1     1     NaN     NaN     1     1     1     NaN     NaN     NaN     NaN
    NaN     NaN     NaN     NaN     1     NaN     NaN     NaN     NaN     NaN     1     1     NaN     NaN     NaN     NaN
    NaN     NaN     NaN     NaN     1     NaN     NaN     NaN     NaN     1     NaN     1     NaN     NaN     NaN     NaN
    NaN     NaN     NaN     1     NaN     NaN     NaN     NaN     1     NaN     NaN     NaN     1     NaN     NaN     NaN
    NaN     NaN     NaN     1     NaN     NaN     NaN     1     NaN     NaN     NaN     NaN     1     NaN     NaN     NaN
    NaN     NaN     NaN     NaN     1     NaN     1     NaN     NaN     NaN     NaN     1     NaN     NaN     NaN     NaN
    NaN     NaN     NaN     NaN     1     1     NaN     NaN     NaN     NaN     NaN     1     NaN     NaN     NaN     NaN
    NaN     NaN     NaN     NaN     1     1     1     NaN     NaN     1     1     NaN     NaN     NaN     NaN     NaN
    NaN     NaN     NaN     1     NaN     NaN     NaN     1     1     NaN     NaN     NaN     NaN     NaN     NaN     NaN
    NaN     NaN     NaN     NaN     NaN     NaN     NaN     NaN     NaN     NaN     NaN     NaN     NaN     NaN     NaN     NaN
    NaN     NaN     NaN     NaN     NaN     NaN     NaN     NaN     NaN     NaN     NaN     NaN     NaN     NaN     NaN     NaN
    NaN     NaN     NaN     NaN     NaN     NaN     NaN     NaN     NaN     NaN     NaN     NaN     NaN     NaN     NaN     NaN];