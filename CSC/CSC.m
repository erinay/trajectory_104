classdef CSC < handle  
  properties (Dependent)
      hAxes
      hLine
  end
  properties (Hidden, Access = protected)
      MainAxes
      version    
      statusBox
      hCol
      handles
      fontsize12
      args
      x
      y
      z
      rb_val
      C
  end
  properties (Constant, Hidden, Access = protected)
      ptrTypes = {'hand', 'arrow'}
      wsize = [800 600];
  end
  methods
    % Class Constructor
    function obj = CSC(varargin)
        
        os = getenv('OS');
        if ~isempty(regexp(os,'indow'))
            obj.fontsize12 = 10;
        else
            obj.fontsize12 = 12;
        end
        
        obj.version = '1.0';

        if nargin > 0               
            % Error checking
            errorcheck(obj);
        end

        if mod(nargin-2,2)
            error('Additional arguments must be Param/Value pairs');
        end

        % Create main GUI
        createGUI(obj);

        % Load default parameters
        args = varargin;  
        if isempty(args)
            obj.loadParams('default');
        end
        
    end
    
    % Handle set(app.hAxes) calls
    function out = get.hAxes(obj)
        out = obj.MainAxes;
    end
  end
  methods (Hidden, Access = protected)
%--------------------------------------------------------------------------
% Function for creating the GUI
      function createGUI(obj) 
          % Create main window
          hFig = figure(...
            'Name'                            , 'CSC 1.0', ...
            'Numbertitle'                     , 'off', ...
            'Units'                           , 'pixels', ...
            'DockControls'                    , 'on', ...
            'Toolbar'                         , 'none', ...
            'Menubar'                         , 'none', ...
            'Color'                           , [0 0 0], ...
            'DoubleBuffer'                    , 'on', ...
            'Renderer'                        , 'OpenGL', ...
            'ResizeFcn'                       , @obj.figResizeFcn, ...
            'KeyPressFcn'                     , @obj.keypressFcn, ...
            'DeleteFcn'                       , @obj.figDeleteFcn, ...
            'Visible'                         , 'on', ...
            'HandleVisibility'                , 'callback', ...
            'WindowButtonMotionFcn'           , @obj.motionFcn, ...
            'Tag'                             , 'MainFigure', ...
            'defaultUIControlBackgroundColor' , 'w', ...
            'defaultUIControlFontName'        , 'Arial', ...
            'defaultUIControlFontSize'        , obj.fontsize12, ...
            'defaultUIPanelUnits'             , 'pixels', ...
            'defaultUIPanelPosition'          , [0 0 obj.wsize(1) 50], ...
            'defaultAxesUnits'                , 'pixels', ...              
            'defaultAxesXColor'               , 'w', ...
            'defaultAxesYColor'               , 'w', ...
            'defaultAxesZColor'               , 'w', ...
            'defaultAxesFontName'             , 'Arial', ...
            'defaultAxesFontSize'             , obj.fontsize12, ...
            'defaultAxesPosition'             , [385 180 440 330], ...
            'Position'                        , [0 0 obj.wsize] ...
          );
          cameratoolbar(hFig,'show','NoReset')
      
          % Create main axes
          obj.MainAxes = axes('Parent', hFig);
 
          obj.initializeMainAxes();
          
          % Create Processing Parameters menu
          hMenu0 = uimenu('Parent', hFig,  'Label','Processing Parameters');
          % Create View Sub-Menu
          uimenu('Parent', hMenu0, 'Label', 'View...',...
                 'Callback', @obj.viewParams);          
          % Create Edit Sub-Menu
          uimenu('Parent', hMenu0, 'Label', 'Edit...',...
                 'Callback', @obj.editParams);

          % Create Plot Options menu
          hMenu1 = uimenu('Parent', hFig,  'Label','Plot Options');             
          uimenu('Parent', hMenu1, 'Label', 'Clear Axes...',...
                 'Callback', @obj.resetAxes);
          uimenu('Parent', hMenu1, 'Label', 'Edit Title/Labels...',...
                 'Callback', @obj.labelCallback);
          hThemeMenu = uimenu( ...
                              'Parent'    , hMenu1,...
                              'Tag'       , 'ThemeSel', ...
                              'Label'     , 'Change Theme...' ...
                              );
          hTheme(1) = uimenu('Parent',hThemeMenu,'Label','Black');
          hTheme(2) = uimenu('Parent',hThemeMenu,'Label','Blue');
          hTheme(3) = uimenu('Parent',hThemeMenu,'Label','White');
          set(hTheme, {'Checked'} , {'on'; 'off'; 'off'}, ...
                      'Callback', @obj.changeThemeFcn);
          uimenu('Parent', hFig, 'Label', 'Help'             , ... 
                 'Callback', @obj.helpFcn, 'Separator', 'on');
          uimenu('Parent', hFig, 'Label', 'About'            ,...
                 'Callback', @obj.aboutFcn);
          % UI Context Menu for plot customization
          hContext = uicontextmenu('Parent', hFig, 'Tag', 'ContextMenu');
          hCPlotOptions = uimenu('Parent', hContext, 'Label', 'Plot Options');
          hContextMenuItems(1) = uimenu('Parent', hCPlotOptions, 'Label', 'Clear axes');

          set(hContextMenuItems, 'Callback', @obj.contextmenuFcn);

          % Folder selection text boxes and corresponding labels
          uicontrol(...
              'Parent'              , hFig, ...
              'style'               , 'text', ...
              'HorizontalAlignment' , 'center', ...
              'FontWeight'          , 'Bold', ...
              'BackgroundColor'     , [.8 .8 .8], ...
              'String'              , 'Particle Data Folder', ...
              'Position'            , [20 475 250 18] ...
          );
          uicontrol(...
              'Parent'              , hFig, ...
              'style'               , 'text', ...
              'Tag'                 , 'partDataFolderTxt', ...
              'HorizontalAlignment' , 'left', ...
              'FontWeight'          , 'Bold', ...
              'Position'            , [20 450 250 24] ...
          );
          uicontrol(...
              'Parent'              , hFig, ...
              'style'               , 'text', ...
              'HorizontalAlignment' , 'center', ...
              'FontWeight'          , 'Bold', ...
              'BackgroundColor'     , [.8 .8 .8], ...
              'String'              , 'Input Parameters File', ...
              'Position'            , [20 305 250 18] ...
          );
          uicontrol(...
              'Parent'              , hFig, ...
              'style'               , 'text', ...
              'Tag'                 , 'iParamFileTxt', ...
              'HorizontalAlignment' , 'left', ...
              'FontWeight'          , 'Bold', ...
              'Position'            , [20 280 250 24] ...
          );
          % Folder selection buttons
          uicontrol(...
              'Parent'            , hFig, ...
              'Style'             , 'pushbutton', ...
              'Tag'               , 'partDataFolder', ...
              'Position'          , [285 460 60 24], ...
              'String'            , 'Browse', ...
              'ToolTipString'     , ''  , ...
              'Callback'          , @obj.setDataFolder ...
          );
          uicontrol(...
              'Parent'            , hFig, ...
              'Style'             , 'pushbutton', ...
              'Tag'               , 'iParamFile', ...
              'Position'          , [285 280 60 24], ...
              'String'            , 'Browse', ...
              'ToolTipString'     , '', ...
              'Callback'          , @obj.setDataFolder ...
          );
          % Radio buttons
          uicontrol(...
              'Parent'              , hFig, ...
              'style'               , 'text', ...
              'Tag'                 , 'txt2d', ...
              'HorizontalAlignment' , 'left', ...
              'FontWeight'          , 'Bold', ...
              'Enable'              , 'inactive', ...
              'ForegroundColor'     , 'w', ...
              'BackgroundColor'     , 'k', ...
              'Position'            , [110 420 20 20], ...
              'String'              , '2D' ...
          );
          uicontrol(...
              'Parent'              , hFig, ...
              'Style'               , 'radiobutton', ...
              'Tag'                 , '2d',...
              'Position'            , [90 420 20 20], ...
              'Value'               ,  1, ...
              'ToolTipString'       , '', ...
              'ForegroundColor'     , 'k', ...
              'BackgroundColor'     , 'k', ...
              'Callback'            , @obj.setDim ...
          );
          obj.rb_val = '2d';
          uicontrol(...
              'Parent'              , hFig, ...
              'style'               , 'text', ...
              'Tag'                 , 'txt3d', ...
              'HorizontalAlignment' , 'left', ...
              'FontWeight'          , 'Bold', ...
              'Enable'              , 'inactive', ...
              'ForegroundColor'     , 'w', ...
              'BackgroundColor'     , 'k', ...
              'Position'            , [170 420 20 20], ...
              'String'              , '3D' ...
          );
          uicontrol(...
              'Parent'              , hFig, ...
              'Style'               , 'radiobutton', ...
              'Tag'                 , '3d',...
              'Position'            , [150 420 20 20], ...
              'Value'               , 0, ...
              'ToolTipString'       , '', ...
              'ForegroundColor'     , 'k', ...
              'BackgroundColor'     , 'k', ...
              'Callback'            , @obj.setDim ...
              );
          % Stop button
          uicontrol(...
              'Parent'            , hFig, ...
              'Style'             , 'pushbutton', ...
              'Tag'               , 'Stop!',...
              'Position'          , [120 140 72 72], ...
              'String'            , 'Stop', ...
              'FontSize'          , 20, ...
              'ToolTipString'     , '', ...
              'BackgroundColor'   , 'r', ...
              'ForegroundColor'   , 'w', ...
              'Value'             , 0, ...
              'Callback'          , @obj.stop...
          );
          % Control panel
          hPanel = uipanel(...
              'Parent'            , hFig              , ...
              'BackgroundColor'   , [.5 .5 .5]        , ...
              'Tag'               , 'ControlPanelAxes', ...
              'BorderType'        , 'etchedin'...
          );
          % Create action buttons
          uicontrol(...
              'Parent'            , hPanel, ...
              'Style'             ,'pushbutton', ...
              'Tag'               ,'plot_part', ...
              'Position'          ,[420 5 180 36], ...
              'String'            ,'Plot Particle Fields', ...
              'ToolTipString'     ,'', ...
              'Callback'          , @obj.performAction ...
          );
          uicontrol(...
              'Parent'            , hPanel, ...
              'Style'             , 'pushbutton', ...
              'Tag'               , 'comp_color', ...
              'Position'          , [610 5 180 36], ...
              'String'            , 'Compute Color Fields' , ...
              'ToolTipString'     , '', ...
              'Callback'          , @obj.performAction ...
          );
          % Status message box
          obj.statusBox = uicontrol(...
              'Parent'              , hFig, ...
              'style'               , 'text', ...
              'Tag'                 , 'statusBox', ...
              'HorizontalAlignment' , 'left', ...
              'FontWeight'          , 'Bold', ...
              'FontSize'            , obj.fontsize12, ...
              'String'              , 'Status: ', ...
              'Position'            , [285 560 500 20] ...
          );        
          obj.handles = guihandles(hFig);
          % Make axes invisible from outside
          set(findobj(hFig, 'type', 'axes'),...
              'HandleVisibility', 'callback');         
          movegui(hFig, 'center');
          set(hFig, 'Visible' , 'on');
      end %createGUI
%--------------------------------------------------------------------------
% Function for loading the processing parameters
      function stop(obj,varargin)
            cmdWindow = com.mathworks.mde.cmdwin.CmdWin.getInstance();
            cmdWindow.grabFocus();

            %2) Wait for focus transfer to complete (up to 2 seconds)
            focustransferTimer = tic;
            while ~cmdWindow.isFocusOwner
                pause(0.1);  %Pause some small interval
                if (toc(focustransferTimer) > 2)
                    error('Error transferring focus for CTRL+C press.')
                end
            end

            %3) Use Java robot to execute a CTRL+C in the (now focused) command window.

            %3.1)  Setup a timer to relase CTRL + C in 1 second
            %  Try to reuse an existing timer if possible (this would be a holdover
            %  from a previous execution)
            t_all = timerfindall;
            releaseTimer = [];
            ix_timer = 1;
            while isempty(releaseTimer) && (ix_timer<= length(t_all))
                if isequal(t_all(ix_timer).TimerFcn, @releaseCtrl_C)
                    releaseTimer = t_all(ix_timer);
                end
                ix_timer = ix_timer+1;
            end
            if isempty(releaseTimer)
                releaseTimer = timer;
                releaseTimer.TimerFcn = @releaseCtrl_C;
            end
            releaseTimer.StartDelay = 1;
            start(releaseTimer);

            %3.2)  Press CTRL+C
            pressCtrl_C
      end
%--------------------------------------------------------------------------
% Function for loading the processing parameters
      function loadParams(obj,varargin)
        if strcmp(varargin{1},'default')
            filename = 'CSCinput';
            obj.args = eval(filename);        
            o = obj.handles.iParamFileTxt;
            set(o,'String',[filename '.m']);
            set(o,'ToolTip',[pwd filesep filename '.m']);
        elseif strcmp(varargin{1},'user')
            o = obj.handles.iParamFileTxt;
            s = get(o,'String');
            filename = s(1:end-2);
            obj.args = eval(filename);
            clear args;
        end
        o = obj.handles.partDataFolderTxt;
        set(o,'String',obj.args.datafolder);
        set(o,'ToolTip',['Data files: ' obj.args.datafolder filesep obj.args.inroot '*.dat']);
      end
%--------------------------------------------------------------------------
% Function for intializing the plot axes
      function initializeMainAxes(obj,varargin)
          ax = obj.MainAxes;
          hcol= colorbar('Peer'       , ax, ...
                         'Units'      , 'Pixels', ...
                         'Color'      , 'w', ...
                         'YColor'     , 'w', ...
                         'Location'   , 'SouthOutside', ...
                         'FontSize'   , obj.fontsize12, ...
                         'Visible'   , 'off'...
                         );
          cpos=get(hcol,'Position');
          cpos(1)=cpos(1)+cpos(3)/8;
          cpos(2)=100;
          cpos(3)=3*cpos(3)/4; % Halve the thickness
          cpos(4)=cpos(4)/2; % Halve the thickness
          set(hcol,'position',cpos)
          xlabel(hcol,'Color','Color','w')
          obj.hCol = hcol;
          set(ax,'Color','none')
          xlabel (ax,'x (m)','Color','w')
          ylabel (ax,'y (m)','Color','w')
          zlabel (ax,'z (m)','Color','w')
          title(ax,'','Color','w')
          axis(ax,'square')
          box(ax,'off')
          hold(ax,'on')
          caxis(ax,[-1 1]);
      end %initializeMainAxes
%--------------------------------------------------------------------------
% Called when the context menu on a graphics object is selected
      function contextmenuFcn(obj, hObj, varargin) %#ok<INUSL>
          val = get(hObj, 'Label');
          switch get(get(hObj, 'Parent'), 'Label')
              case 'Line Style'
                  set(gco, 'LineStyle', val);
              case 'Line Width'
                  set(gco, 'LineWidth', str2double(val));
              case 'Line Color'
                  set(gco, 'Color', str2num(val)); %#ok<ST2NM>
              case 'Marker'
                  set(gco, 'Marker', val);
              case 'Marker Size'
                  set(gco, 'MarkerSize', str2double(val));
          end
      end %contextmenuFcn
%--------------------------------------------------------------------------
% Checks for file information to be entered
      function ret = checkFileInfo(obj)
          ret = 1;
          box = findobj('Tag','partDataFolderTxt');
          vel = get(box,'ToolTip');
          % Ensure that user has entered the necessary input data
          if ( isempty(vel) )
            % Flash error message if input data are missing
            obj.setMessage(obj.statusBox,'error','Please enter input data!',4)
            obj.setMessage(obj.statusBox,'default','',0)
            ret = 0;
          end
      end
%--------------------------------------------------------------------------
% Plots raw input data (particle fields) for verifying if it is in the 
% correct format
      function plotParticles(obj)
        dim = 2;
        o = findobj('Tag','3d');
        if (get(o(1),'Val')==1) 
          dim = 3;
        end
        obj.resetAxes();
        obj.setMessage(obj.statusBox,'status',...
                       'Verifying input file...',...
                       .25);        
        caxis(obj.MainAxes,[0 1]);
        set(obj.hCol,'Visible','off');
        
        switch dim
            case 2
              for n = obj.args.first:obj.args.increment:obj.args.last
                    fnamep=[obj.args.datafolder filesep obj.args.inroot,...
                    num2str(n, obj.args.numformat) obj.args.fileextension];
                    fnamepprev=[obj.args.datafolder filesep obj.args.inroot,...
                    num2str(max(obj.args.first,n-obj.args.increment), obj.args.numformat) obj.args.fileextension];
                    part = dlmread(fnamep,obj.args.separator,obj.args.numheaderlines,0);  
                    partprev = dlmread(fnamepprev,obj.args.separator,obj.args.numheaderlines,0);
                if size(part,2)~=3
                    errordlg('Wrong number of columns in input file.')
                    obj.setMessage(obj.statusBox,'default','',0)                
                    return
                end
                    a = obj.args;
                    obj.setMessage(obj.statusBox,'status',...
                    ['Plotting particle field number ' num2str(n) ' of ' num2str(obj.args.last)],...
                    1);                               
                    part = sortrows(part,1);    
                    partprev = sortrows(partprev,1);  
                    partx = part(:,2)*obj.args.lengthcalib_axis;
                    party = part(:,3)*obj.args.lengthcalib_axis;
                    partxprev = partprev(:,2)*obj.args.lengthcalib_axis;
                    partyprev = partprev(:,3)*obj.args.lengthcalib_axis;
                    
                    axes(obj.MainAxes);
                    cla(obj.hAxes)
                    quiver(partx,party,partx-partxprev,party-partyprev,'w')
                    hold on
                    plot(partx',party','.','MarkerEdgeColor','w','MarkerFaceColor','w','MarkerSize',2)
                    axis(obj.hAxes,'tight')
                    pause(obj.args.plot_delay)
              end              
            case 3
              for n = obj.args.first:obj.args.increment:obj.args.last
                    fnamep=[obj.args.datafolder filesep obj.args.inroot,...
                    num2str(n, obj.args.numformat) obj.args.fileextension];
                    fnamepprev=[obj.args.datafolder filesep obj.args.inroot,...
                    num2str(max(obj.args.first,n-obj.args.increment), obj.args.numformat) obj.args.fileextension];
                    part = dlmread(fnamep,obj.args.separator,obj.args.numheaderlines,0);  
                    partprev = dlmread(fnamepprev,obj.args.separator,obj.args.numheaderlines,0);
                if size(part,2)~=4
                    errordlg('Wrong number of columns in input file.')
                    obj.setMessage(obj.statusBox,'default','',0)                
                    return
                end                
                    a = obj.args;
                    obj.setMessage(obj.statusBox,'status',...
                    ['Plotting particle field number ' num2str(n) ' of ' num2str(obj.args.last)],...
                    1);                               
                    part = sortrows(part,1);    
                    partprev = sortrows(partprev,1);  
                    partx = part(:,2)*obj.args.lengthcalib_axis;
                    party = part(:,3)*obj.args.lengthcalib_axis;
                    partz = part(:,4)*obj.args.lengthcalib_axis;
                    partxprev = partprev(:,2)*obj.args.lengthcalib_axis;
                    partyprev = partprev(:,3)*obj.args.lengthcalib_axis;
                    partzprev = partprev(:,4)*obj.args.lengthcalib_axis;
                    
                    axes(obj.MainAxes);
                    cla(obj.hAxes)
                    quiver3(partx,party,partz,partx-partxprev,party-partyprev,partz-partzprev,'w')
                    hold on
                    plot3(partx',party',partz','o','MarkerEdgeColor','w','MarkerFaceColor','w','MarkerSize',2)
                    view(obj.hAxes,3)
                    axis(obj.hAxes,'tight')
                    pause(obj.args.plot_delay)
             end
        end
        obj.setMessage(obj.statusBox,'status','DONE!',4)
        obj.setMessage(obj.statusBox,'default','',0)        
      end
%--------------------------------------------------------------------------
% Called when any of the action buttons is clicked
      function performAction(obj, varargin)
        % Check for file input info       
        if ~obj.checkFileInfo();
            return
        end
        obj.loadParams('user');
        % Determine which action is to be performed
        buttonTag = get(varargin{1},'Tag');
        switch buttonTag
          case 'plot_part'
            obj.plotParticles()
            return
          case 'comp_color'
            obj.args.plotfigure = 1;
        end
        % 2d/3d case according to selected radio button
        dim = 2;
        o = findobj('Tag','3d');
        if (get(o(1),'Val')==1) 
          dim = 3;
        end
        % Call to process data using .p file
        try
            obj.CSCFcn(dim);
        catch err
            errordlg(err.message);
            % Flash error message if input data are missing
                obj.setMessage(obj.statusBox,'error','Error executing script!',4)
            try
                obj.setMessage(obj.statusBox,'default','',0)
            catch
                disp 'Program ended...'
            end
        end
      end %performAction
%--------------------------------------------------------------------------
% Called when the radio buttons (2d/3d) are pressed
      function setDim(obj, varargin)
          
        % Determine which action is to be performed
        buttonTag = get(varargin{1},'Tag');
        
        if ~strcmp(obj.rb_val,buttonTag)
            obj.rb_val = buttonTag;
        else
            set(varargin{1},'Value',1)            
            return;
        end
        
        switch buttonTag
          case '2d'
            o = findobj('Tag','3d');
            set(o,'Value',0);
          case '3d'
            o = findobj('Tag','2d');
            set(o,'Value',0);
        end
        obj.resetAxes();
      end
%--------------------------------------------------------------------------
% Called when the browse buttons are pressed
      function setDataFolder(obj, varargin)
        buttonTag = get(varargin{1},'Tag');
        boxTag = [buttonTag 'Txt'];
        box = findobj('Tag',boxTag);

        switch buttonTag
          case 'partDataFolder'
            dirpath = uigetdir;
            % Check if user hits cancel
            if dirpath==0
              return;
            end
            dirname =  regexp(dirpath,filesep,'split');
            files = dir(fullfile(dirpath,'*.dat'));
            if size(files,1)==0
                obj.setMessage(obj.statusBox,'error','No data (.dat) files found!',4)
                obj.setMessage(obj.statusBox,'default','',0)
                set(box,'String','','ToolTip','');
                return;
            end
            
            filename = files(1,1).name;
            inroot = regexp(filename,'\.','split');
            inroot = inroot{1,1}(1,:);
            strfind(inroot,obj.args.inroot);
%             keyboard
            if (strfind(inroot,obj.args.inroot)==1)
              set(box,'String',dirname(end),'ToolTip',dirpath);
            else
              obj.setMessage(obj.statusBox,'error',...
                         'inroot parameter and file names don''t match!',...
                         4);
              obj.setMessage(obj.statusBox,'default','',0)
              set(box,'String','','ToolTip','');
            end
            
          case 'iParamFile'
            [filename, pathname] = uigetfile( ...
              {'*.m;*.fig;*.mat;*.slx;*.mdl',...
               'MATLAB Files (*.m,*.fig,*.mat,*.slx,*.mdl)';
               '*.m',  'Code files (*.m)'; ...
               '*.fig','Figures (*.fig)'; ...
               '*.mat','MAT-files (*.mat)'; ...
               '*.mdl;*.slx','Models (*.slx, *.mdl)'; ...
               '*.*',  'All Files (*.*)'}, ...
               'Pick a file');
            % Check if user hits cancel
            if filename==0
              return;
            end
            set(box,'String',filename,...
                'ToolTip',[pathname filename]);
            obj.loadParams('user');            
        end
      end %setDataFolder
%--------------------------------------------------------------------------
% Called when "Edit title/labels..." menu is selected
      function labelCallback(obj, varargin)

          answer = inputdlg({'Title:', 'X-Label:', 'Y-Label:', 'Z-Label:'}, ...
              'Enter labels', 1, {get(get(obj.MainAxes, 'Title'), 'String'), ...
              get(get(obj.MainAxes, 'XLabel'), 'String'), ...
              get(get(obj.MainAxes, 'YLabel'), 'String'), ...;
              get(get(obj.MainAxes, 'ZLabel'), 'String')});

          if ~isempty(answer)
              title(obj.MainAxes , answer{1});
              xlabel(obj.MainAxes, answer{2});
              ylabel(obj.MainAxes, answer{3});
              zlabel(obj.MainAxes, answer{3});
          end

      end %labelCallback
%--------------------------------------------------------------------------
% Called when "View Processing Parameters" menu is selected
      function viewParams(obj,varargin)
          obj.loadParams('user');
          c = {paramsCells(obj.args)};
          
          h = figure('Units','pixels',...
                     'Position',[500 500 300 600],...
                     'Menubar','none',...
                     'Name','Processing Parameters',...
                     'Numbertitle','off',...
                     'Resize','off');
          
          l = uicontrol('Parent'      , h, ...
                        'Style'       , 'List', ...
                        'Unit'        , 'Pixels', ...
                        'Position'    , [0 0 280 580],...
                        'Min'         , 0,...
                        'Max'         , 2,...
                        'FontSize'    , obj.fontsize12 ...
                      );
          set(l,'String',c{1});
          movegui(h, 'center');
      end
%--------------------------------------------------------------------------
% Called when "Edit Processing Parameters" menu is selected
      function editParams(obj,varargin)
          o = findobj('Tag','iParamFileTxt');
          filename = get(o(1),'ToolTip');
          edit(filename);          
      end
%--------------------------------------------------------------------------
% Called when "Help..." menu is selected
      function helpFcn(obj, varargin)  %#ok<INUSD>

          helpdlg({'Please consult the README file for additional information.'},...
                   'Help for CSC');

      end %helpFcn
%--------------------------------------------------------------------------
% Called when change theme is selected
      function changeThemeFcn(obj, varargin)
          o = get(varargin{1},'Parent');
          c = get(o,'Children');
          set(c,{'Checked'},{'off';'off';'off'});
          set(varargin{1},'Checked','on');
          hFig = get(obj.MainAxes,'Parent');
          
          switch get(varargin{1},'Label')
            case 'Blue'
              set(hFig,'Color','b')
              set(obj.MainAxes,'XColor','w')
              set(obj.MainAxes,'YColor','w')
              set(obj.MainAxes,'ZColor','w')
              o = findobj('Tag','velDataFolderTxt');
              set(o,'BackgroundColor','w', 'ForegroundColor','k');
              o = findobj('Tag','ifaceDataFolderTxt');
              set(o,'BackgroundColor','w', 'ForegroundColor','k');
              o = findobj('Tag','iParamFileTxt');
              set(o,'BackgroundColor','w', 'ForegroundColor','k');
              s =  get(get(obj.MainAxes, 'XLabel'), 'String');
              xlabel (obj.MainAxes,s,'Color','w')
              s =  get(get(obj.MainAxes, 'YLabel'), 'String');
              ylabel (obj.MainAxes,s,'Color','w')
              s =  get(get(obj.MainAxes, 'ZLabel'), 'String');
              zlabel (obj.MainAxes,s,'Color','w')
              s =  get(get(obj.MainAxes, 'Title'), 'String');
              title (obj.MainAxes,s,'Color','w')
              o = findobj('Tag','txt2d');
              set(o,'BackgroundColor','b', 'ForegroundColor','w');
              o = findobj('Tag','txt3d');
              set(o,'BackgroundColor','b', 'ForegroundColor','w');
              o = findobj('Tag','statusBox');
              set(o,'BackgroundColor','w', 'ForegroundColor','k');
              o = findobj('Tag','3d');
              set(o,'BackgroundColor','b', 'ForegroundColor','b');
              o = findobj('Tag','2d');
              set(o,'BackgroundColor','b', 'ForegroundColor','b');
              xlabel(obj.hCol,'Color','Color','w');
            case 'Black'
              set(hFig,'Color','k')
              set(obj.MainAxes,'XColor','w')
              set(obj.MainAxes,'YColor','w')
              set(obj.MainAxes,'ZColor','w')
              o = findobj('Tag','partDataFolderTxt');
              set(o,'BackgroundColor','w', 'ForegroundColor','k');
              o = findobj('Tag','iParamFileTxt');
              set(o,'BackgroundColor','w', 'ForegroundColor','k');
              s =  get(get(obj.MainAxes, 'XLabel'), 'String');
              xlabel (obj.MainAxes,s,'Color','w')
              s =  get(get(obj.MainAxes, 'YLabel'), 'String');
              ylabel (obj.MainAxes,s,'Color','w')
              s =  get(get(obj.MainAxes, 'ZLabel'), 'String');
              zlabel (obj.MainAxes,s,'Color','w')
              s =  get(get(obj.MainAxes, 'Title'), 'String');
              title (obj.MainAxes,s,'Color','w')              
              o = findobj('Tag','txt2d');
              set(o,'BackgroundColor','k', 'ForegroundColor','w');
              o = findobj('Tag','txt3d');
              set(o,'BackgroundColor','k', 'ForegroundColor','w');
              o = findobj('Tag','statusBox');
              set(o,'BackgroundColor','w', 'ForegroundColor','k');
               o = findobj('Tag','3d');
              set(o,'BackgroundColor','k', 'ForegroundColor','k');
              o = findobj('Tag','2d');
              set(o,'BackgroundColor','k', 'ForegroundColor','k');
              xlabel(obj.hCol,'Color','Color','w');
            case 'White'
              set(hFig,'Color','w')
              set(obj.MainAxes,'XColor','k')
              set(obj.MainAxes,'YColor','k')
              set(obj.MainAxes,'ZColor','k')
              o = findobj('Tag','partDataFolderTxt');
              set(o,'BackgroundColor',[.2 .2 .2], 'ForegroundColor','w');
              o = findobj('Tag','iParamFileTxt');
              set(o,'BackgroundColor',[.2 .2 .2], 'ForegroundColor','w');
              s =  get(get(obj.MainAxes, 'XLabel'), 'String');
              xlabel (obj.MainAxes,s,'Color','k')
              s =  get(get(obj.MainAxes, 'YLabel'), 'String');
              ylabel (obj.MainAxes,s,'Color','k')
              s =  get(get(obj.MainAxes, 'ZLabel'), 'String');
              zlabel (obj.MainAxes,s,'Color','k')
              s =  get(get(obj.MainAxes, 'Title'), 'String');
              title (obj.MainAxes,s,'Color','k')
              o = findobj('Tag','txt2d');
              set(o,'BackgroundColor','w', 'ForegroundColor','k');
              o = findobj('Tag','txt3d');
              set(o,'BackgroundColor','w', 'ForegroundColor','k');
              o = findobj('Tag','statusBox');
              set(o,'BackgroundColor',[.2 .2 .2], 'ForegroundColor','w');
              o = findobj('Tag','3d');
              set(o,'BackgroundColor','w', 'ForegroundColor','w');
              o = findobj('Tag','2d');
              set(o,'BackgroundColor','w', 'ForegroundColor','w');              
             xlabel(obj.hCol,'Color','Color','k');
          end
          
          if strcmp(s,'Select a file to enable.')
            set(o,'ForegroundColor','r');
          end
      end
%--------------------------------------------------------------------------
% Called when "About..." menu is selected
      function aboutFcn(obj, varargin)

          helpdlg({
              'This program takes as input two or more text files with ' ... 
              '2D or 3D particle field data, and computes the corresponding '...
              'coherent structure coloring field. '...
              ' ', ...
              'Copyright Kristy L. Schlueter and John O. Dabiri 2016'}, ...
              sprintf('About CSC %s', obj.version));

      end %aboutFcn      
%--------------------------------------------------------------------------
% Called when a key is pressed
      function keypressFcn(obj, varargin)
          k = get(obj.handles.MainFigure, 'CurrentKey');
          switch k
              case 'rightarrow'     % go to the next frame
              case 'leftarrow'      % go to the previous frame
              case 'uparrow'
              case 'downarrow'
          end
      end %keypressFcn
%--------------------------------------------------------------------------
% Called whenever the figure is resized to reposition the components
% "nicely"
      function figResizeFcn(obj, varargin)

      end %figResizeFcn
%--------------------------------------------------------------------------
% Called when the cursor is moved (useful to change the pointer icon)
      function motionFcn(obj, varargin)

      end %motionFcn
%--------------------------------------------------------------------------
% Called when figure is closed
      function figDeleteFcn(obj, varargin)
        delete(obj);
        cleanup;
      end %figDeleteFcn
%--------------------------------------------------------------------------
% Error checking
      function errorcheck(obj)

      end %errorcheck
%--------------------------------------------------------------------------
% Reset figure axes      
      function resetAxes(obj,varargin)
        % 2d/3d case according to selected radio button
        dim = 2;
        
        if isempty(varargin)
            % From this app instance
            o = findobj('Tag','3d');
            if (get(o(1),'Val')==1) 
              dim = 3;
            end
        else
            % From clear menu
            o = findobj('Tag','3d');
            if (get(o(1),'Val')==1) 
              dim = 3;
            end
        end
        cla(obj.hAxes)
        switch dim
            case 2
                view(obj.hAxes,0,90); 
                set(obj.hAxes,'XLim',[0 1],'YLim',[0 1],'ZLim',[-1 1])
                set(obj.hCol,'Visible','on');
                xlabel(obj.hCol,'Color');
                set(obj.hAxes,'Position',[385 180 440 330])
                caxis(obj.hAxes,[0 1]);
                set(obj.hAxes,'Color','None')
                colormap jet
            case 3
                view(obj.hAxes,3); 
                set(obj.hAxes,'XLim',[0 1],'YLim',[0 1],'ZLim',[0 1])
                set(obj.hCol,'Visible','off');
                set(obj.hAxes,'Position',[405 200 360 270])
                caxis(obj.hAxes,[0 1]);
                set(obj.hAxes,'Color','None')                  
        end
        title(obj.hAxes,'');
        pause(0.25)
      end     
%--------------------------------------------------------------------------
% Status messages
      function setMessage(obj,varargin)
        textBox = varargin{1};
        type = varargin{2};
        msg = varargin{3};
        delay = varargin{4};
        switch type
          case 'default'
            set(textBox               , ...
                'String'              , 'Status: ', ...
                'HorizontalAlignment' , 'left' ...
                );
          t = findobj('Tag','ThemeSel');
          if length(t)>1
             t = t(1);
          end
          c = get(t,'Children');
          try
            o = get(c,'Checked');
          catch
            o = get(c{1},'Checked');
          end
          w = strcmp(o,'on');

          obj.changeThemeFcn(c(w));
          case 'status'
            set(textBox               , ...
                'String'              , msg, ...
                'BackgroundColor'     , [0 .4 0], ...
                'HorizontalAlignment' , 'center', ...
                'ForegroundColor'     , 'w'...
                )
          case 'error'
            set(textBox               , ...
                'String'              , msg, ...
                'BackgroundColor'     , [1 0 0], ...
                'HorizontalAlignment' , 'center', ...
                'ForegroundColor'     , 'w'...
                )
        end
        pause(delay)
      end
%--------------------------------------------------------------------------
% Main processing function     
      function CSCFcn(obj,varargin)
        warning off;  
        dim  = varargin{1};
        fnamep=[obj.args.datafolder filesep obj.args.inroot,...
                    num2str(obj.args.first, obj.args.numformat) obj.args.fileextension];
        part = dlmread(fnamep,obj.args.separator,obj.args.numheaderlines,0);  
        
        numparts = numel(unique(part(:,1)));            % number of particles
        inttime = obj.args.numparticlefields;           % interval for evaluation of coherence
        
        switch dim
            case 2
                partx = zeros(numparts,floor((obj.args.last-obj.args.first+1)/obj.args.increment));     % initialize matrices to hold particle positions
                party = zeros(numparts,floor((obj.args.last-obj.args.first+1)/obj.args.increment));
            case 3
                partx = zeros(numparts,floor((obj.args.last-obj.args.first+1)/obj.args.increment));
                party = zeros(numparts,floor((obj.args.last-obj.args.first+1)/obj.args.increment));
                partz = zeros(numparts,floor((obj.args.last-obj.args.first+1)/obj.args.increment));
        end
        
        tind=0;
        
        
        % read in all particle trajectories and form partx, party, and
        % partz matrices, size (n x t)
        
        for t=obj.args.first:obj.args.increment:obj.args.last
            tind=tind+1;
            fnamep=[obj.args.datafolder filesep obj.args.inroot,...
                num2str(t, obj.args.numformat) obj.args.fileextension];
            part = dlmread(fnamep,obj.args.separator,obj.args.numheaderlines,0);
            
            switch dim
                case 2
                    if size(part,2)~=3
                        errordlg('Wrong number of columns in input file.')
                        obj.setMessage(obj.statusBox,'default','',0)                
                        return
                    end  

                    partx(:,tind) = part(:,2)*obj.args.lengthcalib_axis;
                    party(:,tind) = part(:,3)*obj.args.lengthcalib_axis;
                case 3
                    if size(part,2)~=4
                        errordlg('Wrong number of columns in input file.')
                        obj.setMessage(obj.statusBox,'default','',0)                
                        return
                    end  
              
                    partx(:,tind) = part(:,2)*obj.args.lengthcalib_axis;
                    party(:,tind) = part(:,3)*obj.args.lengthcalib_axis;
                    partz(:,tind) = part(:,4)*obj.args.lengthcalib_axis;
            end
        end
        
        switch dim
            case 2
                x = linspace(min(min(partx)),max(max(partx)),obj.args.xoutnodes);
                y = linspace(min(min(party)),max(max(party)),obj.args.youtnodes);
                [X,Y] = meshgrid(x,y);
            case 3
                x = linspace(min(min(partx)),max(max(partx)),obj.args.xoutnodes);
                y = linspace(min(min(party)),max(max(party)),obj.args.youtnodes);
                z = linspace(min(min(partz)),max(max(partz)),obj.args.zoutnodes);
                [X,Y,Z] = meshgrid(x,y,z); 
        end
        
        frame=0;
        
        for n = obj.args.export_first:obj.args.export_increment:obj.args.export_last
            tic
          frame=frame+1;
          obj.resetAxes();
          obj.setMessage(obj.statusBox,'status',...
                             ['Calculating CSC field number ' num2str(frame) ' of ' num2str(ceil((obj.args.export_last-obj.args.export_first+1)/obj.args.export_increment))],...
                             .25);
          t_start = n-inttime+1;
          if t_start<1
              t_start=1;
          end
          t_end = n;
          tspan=t_start:t_end;

          switch dim
            case 2

              % Construct adjacency and data frequency matrices       
              if n ~= obj.args.first
                  partindex_inframe = find(~isnan(partx(:,n)) & ~isnan(party(:,n)));
                  partx_inframe = partx(partindex_inframe,tspan);
                  party_inframe = party(partindex_inframe,tspan);
                  numparts_inframe = size(partx_inframe,1);

                  A = zeros(numparts_inframe,numparts_inframe);
                  
                  for i=1:numparts_inframe
                      D=((repmat(partx_inframe(i,:),numparts_inframe,1)-partx_inframe).^2+(repmat(party_inframe(i,:),numparts_inframe,1)-party_inframe).^2).^0.5;
                      A(:,i)=nanstd(D,0,2)./nanmean(D,2);
                      A(i,i)=0;
                  end
              else
                  partindex_inframe = find(~isnan(partx(:,frame)) & ~isnan(party(:,frame)));
                  partx_inframe = partx(partindex_inframe,tspan);
                  party_inframe = party(partindex_inframe,tspan);
                  numparts_inframe = size(partx_inframe,1);
                  
                  A=eye(numparts_inframe);
              end   
              
              % Delete rows/colums of zeros (corresponding to particles
              % that do not overlap with any frames of all other particles)
              Adegree = sum(A,2);
              Asingular=find(Adegree==0);
              A(Asingular,:)=[];
              A(:,Asingular)=[];
              partindex_inframe(Asingular)=[];
              partx_inframe(Asingular,:)=[];
              party_inframe(Asingular,:)=[];
              
              % Compute color field
              Adegree = sum(A,2);
              DD = diag(Adegree);
              L = DD-A;
              %[eigvec, eigval] = eigs(L,DD,2,'lm');
              [eigvec, eigval] = eig(L,DD);
              
              [~, lambdaindex] = sort(diag(eigval),'ascend');
              CSC_vec=eigvec(:,lambdaindex(end));
              
              % Create interpolated coloring field
              C = griddata(partx_inframe(:,end),party_inframe(:,end),CSC_vec,X,Y);
              
              % Plot figure
              if obj.args.plotfigure == 1
                set(obj.hAxes,'Color','w')                  
                contourf(obj.hAxes,X,Y,C,60,'LineColor','none');
                axis(obj.hAxes,'tight')
                title(['CSC FIELD FOR PARTICLE FIELD #' num2str(n)])
                caxislimit = max(max(abs(C)));
                caxis(obj.hAxes,[-caxislimit caxislimit]);
                colormap jet
                pause(obj.args.plot_delay)
              end

              % Write data to file
              if obj.args.export_data == 1
                switch obj.args.export_format
                    case 'ascii'
                        obj.setMessage(obj.statusBox,'status',...
                                       'Exporting data to ASCII file...',...
                                       1);
                        dlmwrite([obj.args.datafolder filesep obj.args.outroot '_colorvector_' num2str(n,obj.args.numformat), ...
                                  obj.args.fileextension],cat(2,partindex_inframe,partx_inframe(:,end),party_inframe(:,end),CSC_vec));
                        dlmwrite([obj.args.datafolder filesep obj.args.outroot '_colorfield_' num2str(n,obj.args.numformat), ...
                                  obj.args.fileextension],cat(2,reshape(X,numel(X),1),reshape(Y,numel(Y),1),reshape(C,numel(C),1)));
                    case 'tecplot'
                        obj.setMessage(obj.statusBox,'status',...
                               'Exporting data to Tecplot file...',...
                               1);
                           
                           colorvector = [partindex_inframe partx_inframe(:,end) party_inframe(:,end) CSC_vec];
                           colorfield = [reshape(X,numel(X),1) reshape(Y,numel(Y),1) reshape(C,numel(C),1)];
                           
                           
                        if n == obj.args.first
                           pid1 = fopen([obj.args.datafolder filesep obj.args.outroot 'combinedcolorvectors' obj.args.fileextension],'w');    
                           pid2 = fopen([obj.args.datafolder filesep obj.args.outroot 'combinedcolorfields' obj.args.fileextension],'w');  
                           fprintf(pid1,'TITLE = color vector\n');
                           fprintf(pid1,['VARIABLES = particle ID (1), x(m), y(m), color (1)']);
                           fprintf(pid2,'TITLE = color field\n');
                           fprintf(pid2,['VARIABLES = x(m), y(m), color (1)']);
                        else
                           pid1 = fopen([obj.args.datafolder filesep obj.args.outroot 'combinedcolorvectors' obj.args.fileextension],'a');    
                           pid2 = fopen([obj.args.datafolder filesep obj.args.outroot 'combinedcolorfields' obj.args.fileextension],'a');    
                        end
                        fprintf(pid1,['ZONE T= colorvector_' num2str(n) ', F=POINT\n']);
                        fprintf(pid1,'%12.8f %12.8f %12.8f %12.8f \n', colorvector');
                        fclose(pid1);
                        fprintf(pid2,['ZONE T= colorfield_' num2str(n) ' I=' num2str(obj.args.xoutnodes)...
                                     ', J=' num2str(obj.args.youtnodes) ', F=POINT\n']);
                        fprintf(pid2,'%12.8f %12.8f %12.8f \n', colorfield');
                        fclose(pid2);
                end
              end
            case 3
              if size(part,2)~=4
                 errordlg('Wrong number of columns in input file.')
                 obj.setMessage(obj.statusBox,'default','',0)                
                 return
              end  
                
              % Construct adjacency and data frequency matrices       
              if n ~= obj.args.first
                  partindex_inframe = find(~isnan(partx(:,n)) & ~isnan(party(:,n)) & ~isnan(partz(:,n)));
                  partx_inframe = partx(partindex_inframe,tspan);
                  party_inframe = party(partindex_inframe,tspan);
                  partz_inframe = partz(partindex_inframe,tspan);
                  numparts_inframe = size(partx_inframe,1);

                  A = zeros(numparts_inframe,numparts_inframe);
                  
                  for i=1:numparts_inframe
                      D=((repmat(partx_inframe(i,:),numparts_inframe,1)-partx_inframe).^2+...
                         (repmat(party_inframe(i,:),numparts_inframe,1)-party_inframe).^2+...
                         (repmat(partz_inframe(i,:),numparts_inframe,1)-partz_inframe).^2).^0.5;
                      A(:,i)=nanstd(D,0,2)./nanmean(D,2);
                      A(i,i)=0;
                  end
              else
                  partindex_inframe = find(~isnan(partx(:,frame)) & ~isnan(party(:,frame)) & ~isnan(partz(:,frame)));
                  partx_inframe = partx(partindex_inframe,tspan);
                  party_inframe = party(partindex_inframe,tspan);
                  partz_inframe = partz(partindex_inframe,tspan);
                  numparts_inframe = size(partx_inframe,1);
                  
                  A=eye(numparts_inframe);
              end   
              
              % Delete rows/colums of zeros (corresponding to particles
              % that do not overlap with any frames of all other particles)
              Adegree = sum(A,2);
              Asingular=find(Adegree==0);
              A(Asingular,:)=[];
              A(:,Asingular)=[];
              partindex_inframe(Asingular)=[];
              partx_inframe(Asingular,:)=[];
              party_inframe(Asingular,:)=[];
              partz_inframe(Asingular,:)=[];
              
              % Compute color field
              Adegree = sum(A,2);
              DD = diag(Adegree);
              L = DD-A;
              %[eigvec eigval] = eigs(L,DD,1,'lm');
              [eigvec, eigval] = eig(L,DD);
              
              [~, lambdaindex] = sort(diag(eigval),'ascend');
              CSC_vec=eigvec(:,lambdaindex(end));
              
              % Create interpolated coloring field
              C = griddata(partx_inframe(:,end),party_inframe(:,end),partz_inframe(:,end),CSC_vec,X,Y,Z);
              
              % Plot figure
              if obj.args.plotfigure == 1
                  p = patch(isosurface(X,Y,Z,C,nanmedian(nanmedian(nanmedian(abs(C))))));
                  title({'MEDIAN COLOR MAGNITUDE ISOSURFACE';['FOR PARTICLE FIELD #' num2str(n)]},'FontWeight','bold')
                  set(p,'FaceColor','green','EdgeColor','none');
                  axis(obj.hAxes,'tight')
                  daspect(obj.hAxes,[1,1,1])
                  camlight 
                  lighting gouraud
                  view(obj.hAxes,3)
                  pause(obj.args.plot_delay)
              end
              
              % Write data to file
              if obj.args.export_data == 1
                switch obj.args.export_format
                    case 'ascii'
                        obj.setMessage(obj.statusBox,'status',...
                                       'Exporting data to ASCII file...',...
                                       1);
                        dlmwrite([obj.args.datafolder filesep obj.args.outroot '_colorvector_' num2str(n,obj.args.numformat), ...
                                  obj.args.fileextension],cat(2,partindex_inframe,partx_inframe(:,end),party_inframe(:,end),partz_inframe(:,end),CSC_vec));
                        dlmwrite([obj.args.datafolder filesep obj.args.outroot '_colorfield_' num2str(n,obj.args.numformat), ...
                                  obj.args.fileextension],cat(2,reshape(X,numel(X),1),reshape(Y,numel(Y),1),reshape(Z,numel(Z),1),reshape(C,numel(C),1)));
                    case 'tecplot'
                        obj.setMessage(obj.statusBox,'status',...
                               'Exporting data to Tecplot file...',...
                               1);
                           
                           colorvector = [partindex_inframe partx_inframe(:,end) party_inframe(:,end) partz_inframe(:,end) CSC_vec];
                           colorfield = [reshape(X,numel(X),1) reshape(Y,numel(Y),1) reshape(Z,numel(Z),1) reshape(C,numel(C),1)];
                           
                           
                        if n == obj.args.first
                           pid1 = fopen([obj.args.datafolder filesep obj.args.outroot 'combinedcolorvectors' obj.args.fileextension],'w');    
                           pid2 = fopen([obj.args.datafolder filesep obj.args.outroot 'combinedcolorfields' obj.args.fileextension],'w');  
                           fprintf(pid1,'TITLE = color vector\n');
                           fprintf(pid1,'VARIABLES = particle ID (1), x(m), y(m), z(m), color (1)');
                           fprintf(pid2,'TITLE = color field\n');
                           fprintf(pid2,'VARIABLES = x(m), y(m), z(m), color (1)');
                        else
                           pid1 = fopen([obj.args.datafolder filesep obj.args.outroot 'combinedcolorvectors' obj.args.fileextension],'a');    
                           pid2 = fopen([obj.args.datafolder filesep obj.args.outroot 'combinedcolorfields' obj.args.fileextension],'a');    
                        end
                        fprintf(pid1,['ZONE T= colorvector_' num2str(n) ', F=POINT\n']);
                        fprintf(pid1,'%12.8f %12.8f %12.8f %12.8f %12.8f \n', colorvector');
                        fclose(pid1);
                        fprintf(pid2,['ZONE T= colorfield_' num2str(n) ' I=' num2str(obj.args.xoutnodes)...
                                     ', J=' num2str(obj.args.youtnodes) ', K=' num2str(obj.args.zoutnodes) ', F=POINT\n']);
                        fprintf(pid2,'%12.8f %12.8f %12.8f %12.8f \n', colorfield');
                        fclose(pid2);
                end
              end
          end
        end
        obj.setMessage(obj.statusBox,'status','DONE!',4)
        obj.setMessage(obj.statusBox,'default','',0)
      end
  end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Helper Functions
%--------------------------------------------------------------------------
% Housekeeping
function cleanup
  close all; clear; clc
end
function c = paramsCells(s)
  f = fields(s);
  for i = 1:size(f,1)
    if ischar(getfield(s,f{i}))
      val = getfield(s,f{i});
    else
      val = num2str(getfield(s,f{i}));
    end   
    c{i,1} = [f{i} ' : ' val];
  end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pressCtrl_C
    import java.awt.Robot;
    import java.awt.event.*;
    SimKey=Robot;
    SimKey.keyPress(KeyEvent.VK_CONTROL);
    SimKey.keyPress(KeyEvent.VK_C);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function releaseCtrl_C(~, ~)
    import java.awt.Robot;
    import java.awt.event.*;
    SimKey=Robot;
    SimKey.keyRelease(KeyEvent.VK_CONTROL);
    SimKey.keyRelease(KeyEvent.VK_C);
end