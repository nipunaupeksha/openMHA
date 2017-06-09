function sLib = libmhagui()
% LIBMHAGUI - function handle library
%
% Usage:
% libmhagui()
%
% Help to function "fun" can be accessed by calling
% mhagui.help.fun()
%

% This file was generated by "bake_mlib mhagui".
% Do not edit! Edit sources mhagui_*.m instead.
%
% Date: 09-Jun-2017 14:42:43
sLib = struct;
sLib.audprof_edit = @mhagui_audprof_edit;
sLib.help.audprof_edit = @help_audprof_edit;
sLib.audprof_plot = @mhagui_audprof_plot;
sLib.help.audprof_plot = @help_audprof_plot;
sLib.client_edit = @mhagui_client_edit;
sLib.help.client_edit = @help_client_edit;
sLib.figure = @mhagui_figure;
sLib.help.figure = @help_figure;
sLib.rating_axes = @mhagui_rating_axes;
sLib.help.rating_axes = @help_rating_axes;
sLib.restore_windowpos = @mhagui_restore_windowpos;
sLib.help.restore_windowpos = @help_restore_windowpos;
sLib.store_windowpos = @mhagui_store_windowpos;
sLib.help.store_windowpos = @help_store_windowpos;
sLib.waitfor = @mhagui_waitfor;
sLib.help.waitfor = @help_waitfor;
assignin('caller','mhagui',sLib);


function sAud = mhagui_audprof_edit( sClientID, sAud )
  libaudprof();
  if nargin < 1
    sClientID = '';
  end
  if nargin < 2
    sAud = audprof.audprof_new();
  end
  sAud.client_id = sClientID;
  sAud = audprof.audprof_fillnan( sAud );
  fh = mhagui_figure(sprintf('Auditory profile editor for ''%s''.',sClientID),...
		     'mhagui_audprof_edit',...
		     [740,540],'UserData',sAud);
  draw_aud_editor(fh);
%  uicontrol('Style','PushButton','Position',[330,220-42,180,32],...
%	    'String','add ACALOS from file',...
%	    'Callback',@mhagui_audprof_edit_acalos);
%  uicontrol('Style','PushButton','Position',[330+180+10,220-42,180,32],...
%	    'String','remove ACALOS data',...
%	    'Tag','rmacalos',...
%	    'Enable',mhagui_audprof_edit_acalos_en(sAud),...
%	    'Callback',@mhagui_audprof_edit_rmacalos);
%  uicontrol('Style','PushButton','Position',[330,220-84,180,32],...
%	    'String','audiogram from ACALOS',...
%	    'Tag','acalos2aud',...
%	    'Enable',mhagui_audprof_edit_acalos_en(sAud),...
%	    'Callback',@mhagui_audprof_edit_acalos2aud);
  %
  uicontrol(fh,'Style','text','String','auditory profile ID',...
	    'Position',[330,99,280,18],...
	    'FontWeight','bold','fontsize',8,'HorizontalAlignment','left');
  uicontrol('Style','Edit','Position',[330,76,280,23],...
	    'String',sAud.id,...
	    'Callback',@mhagui_audprof_edit_audid,...
	    'Tag','aud.id',...
	    'BackgroundColor',[1,1,1],'HorizontalAlignment','left');
  uicontrol('Style','PushButton','Position',[620,76,80,23],...
	    'String','set date ID',...
	    'Callback',@mhagui_audprof_edit_audid2date);
  %
  axes('Units','Pixels','Position',[70,40,240,172],'Tag', ...
       'audiogram_axes');
  mhagui_audprof_plot(sAud);
  sAud = mhagui_waitfor( fh );
  if ~isempty(sAud)
    sAud = audprof.audprof_cleanup( sAud );
  end
  
function draw_aud_editor( fh )
  libaudprof();
  delete(findobj(fh,'Tag','aud.editor'));
  sAud = get(fh,'UserData');
  sCol.l = [0,0,0.7];
  sCol.r = [0.7,0,0];
  dy = 465;
  uicontrol(fh,'style','frame','Position',[20 220 700 300],'tag', ...
	    'aud.editor');
  sAud = audprof.audprof_fillnan( sAud );
  for side='rl'
    uicontrol(fh,'Style','text','String',upper(side),...
	      'Position',[40 dy-82 40 105],...
	      'tag','aud.editor',...
	      'FontWeight','bold','fontsize',32,'ForegroundColor',sCol.(side));
    for type={'htl_ac','htl_bc','ucl'}
      stype = type{:};
      uicontrol(fh,'Style','text','String',stype,...
		'Position',[80 dy 60 23],...
		'tag','aud.editor',...
		'FontWeight','bold','fontsize',12,'ForegroundColor',sCol.(side));
      for kf = 1:numel(sAud.(side).(stype).data)
	sAc = sAud.(side).(stype).data(kf);
	sUD = struct('f',sAc.f,'side',side,'type',stype);
	uicontrol(fh,'Style','text','String',numk2str(sAc.f),...
		  'Position',[140+(kf-1)*50 dy+23 50 18],...
		  'tag','aud.editor',...
		  'FontWeight','bold','fontsize',8);
	uicontrol(fh,'Style','Edit','String',num2str(sAc.hl),...
		  'Callback',@mhagui_audprof_validateentry,...
		  'Position',[140+(kf-1)*50 dy 50 23],...
		  'ForegroundColor',sCol.(side),...
		  'tag','aud.editor',...
		  'BackgroundColor',[1,1,1],...
		  'UserData',sUD);
      end
      dy = dy - 41;
    end
    dy = dy - 20;
  end
  set(fh,'UserData',sAud);

function s = numk2str( v )
  if v<1000
    s = sprintf('%g',v);
  else
    v = v/1000;
    s = sprintf('%dk',floor(v));
    if v-floor(v) > 0
      stmp = sprintf('%g',v-floor(v));
      s = [s,stmp(3:end)];
    end
  end
  
function mhagui_audprof_edit_audid2date( varargin )
  sAud = get(gcbf,'UserData');
  sAud.id = datestr(now,'YYYY-mm-dd HH:MM:SS');
  set(gcbf,'UserData',sAud);
  set(findobj(gcbf,'Tag','aud.id'),'String',sAud.id);
  
function mhagui_audprof_edit_audid( varargin )
  sAud = get(gcbf,'UserData');
  sAud.id = get(gcbo,'String');
  set(gcbf,'UserData',sAud);

function mhagui_audprof_validateentry( varargin )
  libaudprof();
  sAud = get(gcbf,'UserData');
  sPar = get(gcbo,'UserData');
  val = str2num(get(gcbo,'String'));
  if isempty(val)
    val = NaN;
  end
  sAud.(sPar.side).(sPar.type) = ...
      audprof.threshold_entry_add( sAud.(sPar.side).(sPar.type), ...
				   sPar.f, val );
  set(gcbf,'UserData',sAud);
  set(gcbo,'String',num2str(val));
  mhagui_audprof_plot(sAud);
  
function mhagui_audprof_edit_acalos( varargin )
  sAud = get(gcbf,'UserData');
  [fn,p,fi] = uigetfile('*.hfd;*.HFD','Open an ACALOS (hfd) file');
  if ischar(fn)
    libaudprof();
    sAud = audprof.acalos_hfdfile_load( sAud, [p,fn] );
    set(gcbf,'UserData',sAud);
    mhagui_audprof_plot(sAud);
    set(findobj(gcbf,'Tag','acalos2aud'),...
	'Enable',mhagui_audprof_edit_acalos_en(sAud));
    set(findobj(gcbf,'Tag','rmacalos'),...
	'Enable',mhagui_audprof_edit_acalos_en(sAud));
  end

function mhagui_audprof_edit_rmacalos( varargin )
  libaudprof();
  sAud = get(gcbf,'UserData');
  for side='lr'
    if isfield(sAud,side) &&  isfield(sAud.(side),'acalos')
      sAud.(side) = rmfield(sAud.(side),'acalos');
    end
  end
  set(gcbf,'UserData',sAud);
  mhagui_audprof_plot(sAud);
  set(findobj(gcbf,'Tag','acalos2aud'),...
      'Enable',mhagui_audprof_edit_acalos_en(sAud));
  set(findobj(gcbf,'Tag','rmacalos'),...
      'Enable',mhagui_audprof_edit_acalos_en(sAud));

function sEnable = mhagui_audprof_edit_acalos_en( sAud )
  sEnable = 'off';
  for side='lr'
    if isfield(sAud,side) &&  isfield(sAud.(side),'acalos')
      sEnable = 'on';
    end
  end
    
function mhagui_audprof_edit_acalos2aud( varargin )
  libaudprof();
  sAud = get(gcbf,'UserData');
  changed = false;
  for side='lr'
    if isfield(sAud,side) &&  isfield(sAud.(side),'acalos')
      changed = true;
      sAc = sAud.(side).acalos;
      L0 = 0.1*round(10*([sAc.lcut] - 25./[sAc.mlow]));
      L50 = 0.1*round(10*([sAc.lcut] + 25./[sAc.mhigh]));
      sAud.(side).htl_ac = ...
	  audprof.threshold_entry_add([],...
				      [sAc.f],L0);
      sAud.(side).ucl = ...
	  audprof.threshold_entry_add([],...
				      [sAc.f],L50);
    end
  end
  if changed
    set(gcbf,'UserData',sAud);
    draw_aud_editor( gcbf );
    mhagui_audprof_plot(sAud);
  end

function help_audprof_edit
disp([' AUDPROF_EDIT - uicontrol(''Style'',''PushButton'',''Position'',[330,220-42,180,32],...',char(10),'',char(10),' Usage:',char(10),'  mhagui = libmhagui();',char(10),'  sAud = mhagui.audprof_edit( sClientID, sAud );',char(10),'',char(10),'	    ''String'',''add ACALOS from file'',...',char(10),'	    ''Callback'',@mhagui_audprof_edit_acalos);',char(10),'  uicontrol(''Style'',''PushButton'',''Position'',[330+180+10,220-42,180,32],...',char(10),'	    ''String'',''remove ACALOS data'',...',char(10),'	    ''Tag'',''rmacalos'',...',char(10),'	    ''Enable'',mhagui_audprof_edit_acalos_en(sAud),...',char(10),'	    ''Callback'',@mhagui_audprof_edit_rmacalos);',char(10),'  uicontrol(''Style'',''PushButton'',''Position'',[330,220-84,180,32],...',char(10),'	    ''String'',''audiogram from ACALOS'',...',char(10),'	    ''Tag'',''acalos2aud'',...',char(10),'	    ''Enable'',mhagui_audprof_edit_acalos_en(sAud),...',char(10),'	    ''Callback'',@mhagui_audprof_edit_acalos2aud);',char(10),'',char(10),'']);


function ax = mhagui_audprof_plot( sAudProf, ax )
% auditory profile plotting tool
%
% sAudProf : Auditory profile to plot
% ax       : Plot axes
%
% If an axes object with the tag 'audiogram_axes' is found in the
% current figure, then this is used (and returned), otherwise new axes
% are created.
   
  
  libaudprof();
  sAudProf = audprof.audprof_cleanup(sAudProf);
  vFreqMajor = 125*2.^[0:6];
  vFreqMinor = 750*2.^[0:3];
  vHL = [-10:10:120];
  vXLim = [100 10000];
  vYLim = [-15 115];
  if nargin < 2
      ax = findobj('Tag','audiogram_axes');
    if isempty(ax)
      ax = axes('Tag','audiogram_axes');
    else
      hpar = get(ax,'parent');
      if iscell(hpar) % Make shure that the most recent window is updated
        if isoctave 
            [~,IDXlatestFig]=max(cell2mat(hpar));
        else 
            if verLessThan('matlab','8.4') % Matlab < 2014b
                [~,IDXlatestFig]=max(cell2mat(hpar));
            else % Matlab >= 2014b
                vNumFig = [];
                for IDXfig = 1 : size(hpar,1)
                    vNumFig = [vNumFig hpar{IDXfig}.Number];
                end
                [~,IDXlatestFig]=max(vNumFig);
            end
        end
      else
        IDXlatestFig = 1;
      end
      ax = ax(IDXlatestFig); 
    end
  end
  axes(ax);
  set(ax,'NextPlot','ReplaceChildren');
  vH = ...
      plot(sort(repmat(vFreqMajor',[3,1])),...
	   repmat([vYLim,inf]',[7,1]),'k-',...
	   sort(repmat(vFreqMinor',[3,1])),...
	   repmat([vYLim,inf]',[4,1]),'k:',...
	   sort(repmat(vFreqMinor',[3,1])),...
	   repmat([vYLim,inf]',[4,1]),'k:',...
	   repmat([vXLim,inf]',[length(vHL),1]),...
	   sort(repmat(vHL',[3,1])),'k-');
  set(vH,'color',0.7*ones(1,3));
  set(ax,'NextPlot','Add');
  plot(vXLim,[0 0],'k-',[1000 1000],vYLim,'k-');
  sCol = struct;
  sCol.l.c = [0,0,0.7];
  sCol.l.htl_ac.m = 'x';
  sCol.l.htl_bc.m = '';
  sCol.l.htl_bc.t = '>';
  sCol.l.ucl.m = '^';
  sCol.l.df = 1.19;
  sCol.r.c = [0.7,0,0];
  sCol.r.htl_ac.m = 'o';
  sCol.r.htl_bc.m = '';
  sCol.r.htl_bc.t = '<';
  sCol.r.ucl.m = '^';
  sCol.r.df = 1/sCol.l.df;
  for side='lr'
    if isfield(sAudProf,side)
      if isfield(sAudProf.(side),'acalos')
	
	for k=1:numel(sAudProf.(side).acalos)
	  sAc = sAudProf.(side).acalos(k);
	  L0 = sAc.lcut - 25/sAc.mlow;
	  L25 = sAc.lcut;
	  L50 = sAc.lcut + 25/sAc.mhigh;
	  vf1 = [sAc.f;sAc.f;sAc.f*sqrt(sCol.(side).df)];
	  vd1 = [L0;L25;L25];
	  vf2 = [sAc.f;sAc.f*sqrt(sCol.(side).df);sAc.f*sCol.(side).df;sAc.f];
	  vd2 = [L25;L25;L50;L50];
	  patch(vf1,vd1,0.3*sCol.(side).c+0.7*ones(1,3),...
		'EdgeColor',sCol.(side).c);
	  patch(vf2,vd2,0.3*sCol.(side).c+0.7*ones(1,3),...
		'EdgeColor',sCol.(side).c);
	end
      end
    end
  end
  for side='lr'
    if isfield(sAudProf,side)
      for type={'htl_ac','htl_bc','ucl'}
	stype = type{:};
	if isfield(sAudProf.(side),stype)
	  vf = [sAudProf.(side).(stype).data.f];
	  htl = [sAudProf.(side).(stype).data.hl];
	  plot(vf,htl,...
	       ['-',sCol.(side).(stype).m],'linewidth',2,'MarkerSize',10,...
	       'Color',sCol.(side).c);
	  if isfield(sCol.(side).(stype),'t')
	    for kf=1:numel(vf)
	      if isfinite(htl(kf))
		text(vf(kf),htl(kf),sCol.(side).(stype).t,...
		     'FontUnits','normalized','FontSize',0.1,...
		     'FontWeight','bold',...
		     'VerticalAlignment','middle',...
		     'HorizontalAlignment','center',...
		     'Color',sCol.(side).c);
	      end
	    end
	  end
	  idx = find(~isfinite(htl));
	  for kf=idx
	    text(vf(kf),100+floor(sCol.(side).df)*10,'v',...
		 'FontUnits','normalized','FontSize',0.1,...
		 'VerticalAlignment','baseline',...
		 'HorizontalAlignment','center',...
		 'Color',sCol.(side).c);
	    text(vf(kf),100+floor(sCol.(side).df)*10,'I',...
		 'FontUnits','normalized','FontSize',0.1,...
		 'VerticalAlignment','baseline',...
		 'HorizontalAlignment','center',...
		 'Color',sCol.(side).c);
	  end
	end
      end
    end
  end
  csLab = {'125','250','500','1k','2k','4k','8k'};
  set(ax,'XGrid','off','YGrid','off',...
	 'XLim',vXLim,...
	 'XScale','log',...
	 'XTick',vFreqMajor,...
	 'XTickLabel',csLab,...
	 'YDir','reverse',...
	 'YLim',vYLim,...
	 'YTick',vHL,...
	 'Box','on',...
	 'NextPlot','replacechildren');
  xlabel('Frequency / Hz');
  ylabel('Threshold / dB HL');
  title([sAudProf.client_id,', ',sAudProf.id],'interpreter','none');
  drawnow;


function help_audprof_plot
disp([' AUDPROF_PLOT - auditory profile plotting tool',char(10),'',char(10),' Usage:',char(10),'  mhagui = libmhagui();',char(10),'  ax = mhagui.audprof_plot( sAudProf, ax );',char(10),'',char(10),'',char(10),' sAudProf : Auditory profile to plot',char(10),' ax       : Plot axes',char(10),'',char(10),' If an axes object with the tag ''audiogram_axes'' is found in the',char(10),' current figure, then this is used (and returned), otherwise new axes',char(10),' are created.',char(10),'']);


function sClient = mhagui_client_edit( sEditClient )
  sCfg = struct;
  libmhagui();
  libaudprof();
  if nargin < 1
    sCfg.client = audprof.client_new();
    sCfg.client.id = proposed_clientid( sCfg );
    b_edit = 0;
  else
    sCfg.client = merge_structs(sEditClient, ...
				audprof.client_new());
    b_edit = 1;
  end
  sClientEmpty = sCfg.client;
  fh = mhagui.figure('Enter new client data',...
		     'mhagui.client_edit',...
		     [360 260],...
		     'UserData',sCfg);
  vh = [];
  vh(end+1) = ...
      uicontrol_edit_lab( 'First name', [10 200 340], @mhagui_client_edit_update_cb );
  vh(end+1) = ...
      uicontrol_edit_lab( 'Last name', [10 140 340], @mhagui_client_edit_update_cb );
  vh(end+1) = ...
      uicontrol_edit_lab( 'Birthday (YYYY-MM-DD)', [10 80 180], @mhagui_client_edit_update_cb );
  vh(end+1) = ...
      uicontrol_edit_lab( 'Client ID', [210 80 140], @mhagui_client_edit_update_cb );
  if( b_edit )
    set(vh(end),'Enable','off');
  end
  mhagui_client_edit_update_gui( fh );
  sCfg = mhagui.waitfor( fh );
  if isempty(sCfg)
    sClient = [];
    return;
  end
  sClient = sCfg.client;
  if isequal(sClient,sClientEmpty)
    sClient = [];
  else
    if b_edit
      sClient.id = sEditClient.id;
    end
  end

function h = uicontrol_edit_lab( name, pos, fcn )
  pos(length(pos)+1:3) = 120;
  pos(length(pos)+1:4) = 25;
  h = uicontrol('Style','edit','tag',name,...
		'Position',pos,...
		'BackgroundColor',ones(1,3),...
		'HorizontalAlignment','left',...
		'Callback',fcn);
  uicontrol('Style','text','Position',pos+[0 pos(4) 0 -6],...
	    'HorizontalAlignment','left','String',[name,':']);
  
function mhagui_client_edit_update_cb( varargin )
  libaudprof();
  sCfg = get(gcbf,'UserData');
  tag = get(gcbo,'tag');
  val = get(gcbo,'string');
  switch tag
   case 'First name'
    sCfg.client.firstname = val;
   case 'Last name'
    sCfg.client.lastname = val;
   case 'Birthday (YYYY-MM-DD)'
    dn = 0;
    csFmt = {'yyyy-mm-dd','yyyy-mm','yyyy'};
    while (dn == 0) && (~isempty(csFmt))
      try
	dn = datenum(val,csFmt{1});
      catch
	csFmt(1) = [];
      end
    end
    if dn == 0
      fn = datenum('1900','yyyy');
    end
    sCfg.client.birthday = datestr(dn,'yyyy-mm-dd');
   case 'Client ID'
    while audprof.db_client_exists(val)
      val = [val,'_'];
    end
    sCfg.client.id = val;
   otherwise
    warning(['Unhandled tag: ',tag]);
  end
  switch tag
   case {'First name','Last name','Birthday (YYYY-MM-DD)'}
    sCfg.client.id = proposed_clientid(sCfg);
  end
  set(gcbf,'UserData',sCfg);
  mhagui_client_edit_update_gui(gcbf);
  
function id = proposed_clientid( sCfg )
  libaudprof();
  fn = '';
  if isfield(sCfg.client,'firstname')
    fn = sCfg.client.firstname;
  end
  fn(end+1:1) = '_';
  ln = '';
  if isfield(sCfg.client,'lastname')
    ln = sCfg.client.lastname;
  end
  ln(end+1:1) = '_';
  bd = '010101';
  if isfield(sCfg.client,'birthday')
    bd = sCfg.client.birthday;
    bd = datestr(datenum(bd,'yyyy-mm-dd'),'yymmdd');
  end
  id = upper(sprintf('%s%s%s',ln(1),fn(1),bd));
  while audprof.db_client_exists(id)
    id = [id,'_'];
  end
  
function mhagui_client_edit_update_gui( fh )
  sCfg = get(fh,'UserData');
  tags = struct;
  tags.firstname = 'First name';
  tags.lastname = 'Last name';
  tags.birthday = 'Birthday (YYYY-MM-DD)';
  tags.id = 'Client ID';
  for fn=fieldnames(tags)'
    if isfield(sCfg.client,fn{:})
      h = findobj(fh,'tag',tags.(fn{:}));
      set(h,'String',sCfg.client.(fn{:}));
    end
  end


function help_client_edit
disp([' CLIENT_EDIT - ',char(10),'',char(10),' Usage:',char(10),'  mhagui = libmhagui();',char(10),'  sClient = mhagui.client_edit( sEditClient );',char(10),'']);


function fh = mhagui_figure( name, tag, wsize, varargin )
% create a figure handle, remove menu bar and set position
%
% name  : window name
% tag   : window tag (used for identification in position database)
% wsize : window size (position is taken from database, or centered
%         on screen if no entry is found)
%
% Author: Giso Grimm, 3/2011
%
  ScreenSize = get(0,'ScreenSize');
  %cfdb = libconfigdb();
  %bmp = cfdb.readfile('mha_ini.mat','bitmap.logo_uol_htch',ones(0,0,0));
  %bm_y = size(bmp,1);
  %bm_x = size(bmp,2);
  %if bm_y > 0
  %  wsize(2) = wsize(2) + bm_y;
  %  bmp = [repmat(bmp(:,1,:),[1,max(1,wsize(1)-bm_x),1]),bmp];
  %end
  wsize = round([ScreenSize(3:4)/2-wsize/2,wsize]);

  fh = figure('Name',name,...
	      'tag',tag,...
	      'NumberTitle','off','Menubar','none',...
	      'Position',wsize,...
	      'DeleteFcn',@mhagui_store_windowpos,...
	      varargin{:});
  mhagui_restore_windowpos(fh);
  %if bm_y > 0
  %  image(bmp);
  %  set(gca,'Units','normalized','visible','off','Position',[0,(wsize(4)-bm_y)/wsize(4),1,bm_y/wsize(4)]);
  %  %set(gca,'Position',[0,wsize(2)-bm_y,wsize(1),bm_y],...
  %  %	    'visible','on');
  %end

function help_figure
disp([' FIGURE - create a  handle, remove menu bar and set position',char(10),'',char(10),' Usage:',char(10),'  mhagui = libmhagui();',char(10),'  fh = mhagui.figure( name, tag, wsize, varargin );',char(10),'',char(10),'',char(10),' name  : window name',char(10),' tag   : window tag (used for identification in position database)',char(10),' wsize : window size (position is taken from database, or centered',char(10),'         on screen if no entry is found)',char(10),'',char(10),' Author: Giso Grimm, 3/2011',char(10),'',char(10),'']);


function ax = mhagui_rating_axes( csLabel, varargin )
  ylim = [0,length(csLabel)-1];
  dq = 0.03*diff(ylim);
  ax = axes('Visible','on','NextPlot','ReplaceChildren',...
	    'Clipping','off',...
	    'XLim',[0 5],'Ylim',ylim-[dq -dq],...
	    'Box','on','XTick',[],'YTick',[],...
	    'Color',0.9*ones(1,3),...
	    varargin{:});
    q = ylim(1)-ylim(2);
  vhsel = [];
  vhsel(end+1) = ...
      patch([0.05 0.05 1.05 1.05],[ylim(1) ylim(2) ylim(2) ylim(1)],ones(1,3));
  hold on;
  for k=1:length(csLabel)
    %y = (k)/(length(csLabel)+1)*diff(ylim);
    y = (k-1)/(length(csLabel)-1)*diff(ylim);
    vhsel(end+1) = ...
	text(1.4,y,csLabel{k},'HorizontalAlignment','left',...
	     'VerticalAlignment','middle',...
	     'Fontsize',14,'Fontweight','bold');
    if (y < ylim(2)) && (y > ylim(1))
      vhsel(end+1) = ...
	  plot([0.05 1],[y y],'-','Color',0.6*ones(1,3),'linewidth', ...
	       2);
    end
    for kmin=1:3
      y = (k-1+kmin/4)/(length(csLabel)-1)*diff(ylim);
      if (y < ylim(2)) && (y > ylim(1))
	vhsel(end+1) = ...
	    plot([0.05 1],[y y],'--','Color',0.6*ones(1,3),'linewidth', ...
		 1);
      end
    end
  end
  vhsel(end+1) = ax;
  vhsel(end+1) = ...
      plot([0 1 0.5 1 0.5],[q q q+dq q q-dq],...
	   'k-','linewidth',3);
  set(vhsel,'ButtonDownFcn',@mhagui_rating_axes_select);
  set(ax,'UserData',struct('rating',nan,'arrow',vhsel(end),'ylim',ylim));
  
function mhagui_rating_axes_select( varargin )
  ax = gca();
  axp = get(ax,'CurrentPoint');
  sData = get(ax,'UserData');
  ylim = sData.ylim;
  q = axp(1,2);
  %%if (q<ylim(1))||(q>ylim(2))
  %%  return
  %%end
  q = min(max(q,ylim(1)),ylim(2));
  h = sData.arrow;
  q0 = get(h,'YData');
  set(h,'YData',q0-q0(1)+q);
  sData.rating = q;
  set(ax,'UserData',sData);
  if isfield(sData,'callback')
    sData.callback();
  end
  

function help_rating_axes
disp([' RATING_AXES - y = (k)/(length(csLabel)+1)*diff(ylim);',char(10),'',char(10),' Usage:',char(10),'  mhagui = libmhagui();',char(10),'  ax = mhagui.rating_axes( csLabel, varargin );',char(10),'',char(10),'']);


function mhagui_restore_windowpos(fh)
% MHAGUI_RESTORE_WINDOWPOS - restore previously stored window
% position, based on window tag name
%
% Usage:
% mhagui_restore_windowpos(fh)
%
% - fh : figure handle of current window to be restored.
%
% Author: Giso Grimm
% Date: 2007
  ;
  tag = get(fh,'Tag');
  tag = strrep(tag,':','.');
  tag = strrep(tag,' ','_');
  pos = get(fh,'Position');
  tag = sprintf('wndpos.%s',tag);
  fname = 'mhagui_window_positions.mat';
  cfdb = libconfigdb();
  pos(1:2) = cfdb.readfile(fname,tag,pos(1:2));
  set(fh,'Position',pos);


function help_restore_windowpos
disp([' RESTORE_WINDOWPOS - MHAGUI_restore previously stored window',char(10),'',char(10),' Usage:',char(10),'  mhagui = libmhagui();',char(10),'  mhagui.restore_windowpos(fh);',char(10),'',char(10),' position, based on window tag name',char(10),'',char(10),' Usage:',char(10),' mhagui_restore_windowpos(fh)',char(10),'',char(10),' - fh : figure handle of current window to be restored.',char(10),'',char(10),' Author: Giso Grimm',char(10),' Date: 2007',char(10),'']);


function mhagui_store_windowpos( varargin )
% MHAGUI_STORE_WINDOWPOS - Store current window position based on
% window tag
%
% Author: Giso Grimm
% Date: 2007
  ;
  tag = get(gcf,'Tag');
  tag = strrep(tag,':','.');
  tag = strrep(tag,' ','_');
  pos = get(gcf,'Position');
  tag = sprintf('wndpos.%s',tag);
  fname = 'mhagui_window_positions.mat';
  cfdb = libconfigdb();
  cfdb.writefile(fname,tag,pos(1:2));
  


function help_store_windowpos
disp([' STORE_WINDOWPOS - MHAGUI_Store current window position based on',char(10),'',char(10),' Usage:',char(10),'  mhagui = libmhagui();',char(10),'  mhagui.store_windowpos( varargin );',char(10),'',char(10),' window tag',char(10),'',char(10),' Author: Giso Grimm',char(10),' Date: 2007',char(10),'']);


function data = mhagui_waitfor( fh, callback )
% wait for control button or window close, and return figure UserData
% fh : figure handle (optional)
% data : user data, or empty if Cancel or window closed
  
  if nargin < 1
    fh = gcf;
  end
  data = [];
  pos = get(fh,'Position');
  pos = pos(3:4);
  bsize = [80,32];
  uicontrol('Style','PushButton','String','Cancel',...
	    'Position',[pos(1)-200,20,bsize],...
	    'tag','waitfor:cancel',...
	    'Callback',@mhagui_waitfor_cancel);
  h = uicontrol('Style','PushButton','String','Ok',...
		'tag','waitfor:ok',...
		'Callback','uiresume(gcbf)',...
		'Position',[pos(1)-100,20,bsize]);
  if nargin > 1
    callback(fh);
  end
  uiwait(fh);
  if ishandle(fh)
    data = get(fh,'UserData');
    close(fh);
  end
  
function mhagui_waitfor_cancel( varargin )
  close(gcbf);

function help_waitfor
disp([' WAITFOR - wait for control button or window close, and return figure UserData',char(10),'',char(10),' Usage:',char(10),'  mhagui = libmhagui();',char(10),'  data = mhagui.waitfor( fh, callback );',char(10),'',char(10),' fh : figure handle (optional)',char(10),' data : user data, or empty if Cancel or window closed',char(10),'']);


