%% FluOil GUI: FluOil.m
%%%:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::%
%%                       MAIN INTERFACE PROGRAM                           %
%                                                                         %
%%             FLUVIAL EGG DRIFT SIMULATOR (FluOil)                       %
%:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::%
%                                                                         %
%-------------------------------------------------------------------------%
% This interface is used to facilitate the use of the FluOil model        %
% It is modified from the FluEgg model developed by Tatiana Garcia        %
%-------------------------------------------------------------------------%
%                                                                         %
%-------------------------------------------------------------------------%
%   Created by      : Zhenduo Zhu                                         %
%   Last Modified   : January 4, 2018                                     %
%:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::%


function varargout = FluOil(varargin)

% Last Modified by GUIDE v2.5 09-Jul-2019 16:09:29

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @FluOil_OpeningFcn, ...
    'gui_OutputFcn',  @FluOil_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
end

% --- Executes just before FluOil is made visible.
function FluOil_OpeningFcn(hObject, ~, handles, varargin)
handles.output = hObject;
%% Figures and icons
axes(handles.FluOil_Logo); imshow('OPA.png');
axes(handles.riverfig); imshow('riverfig.png');
axes(handles.eggsfig); imshow('oilspill.png');
%ZZ axes(handles.bottom); imshow('OPA.png');
%% Settings
handles.settings=FluOil_Settings;
guidata(hObject, handles);% Update handles structure
end

function varargout = FluOil_OutputFcn(~, ~, handles)
varargout{1} = handles.output;
end

%% River input data::::::::::::::::::::::::::::::::::::::::::::::::::::::%
%                                                                        %
% --- Executes on button press in Load_River_Input.                      %
function Load_River_Input_Callback(hObject,eventdata, handles)
%ZZ create results folder if it does not exist
if  ~exist('./results', 'dir')
    mkdir('./results');
end
if  exist('./results/FluOil_LogFile.txt', 'file')
    delete('./results/FluOil_LogFile.txt')
end
%---------------------
try
    diary('./results/FluOil_LogFile.txt')
catch
    %If log file is not found
    ed = errordlg(' File ./results/FluOil_LogFile.txt not found','Error');
    set(ed, 'WindowStyle', 'modal');
    uiwait(ed);
end
workpath = pwd;setappdata(0,'workpath',workpath);

%% Main handles
setappdata(0,'hFluOilGui',gcf);
setappdata(gcf,   'handlesmain'    , handles);
setappdata(gcf,   'hObjectmain'    , hObject);
setappdata(gcf,   'eventdatamain'    , eventdata);
%setappdata(gcf,   'Batch'    , 0); %for future implementation
setappdata(gcf,'fhRunning',@Running);

%% Open edit river input file sub-GUI
Edit_River_Input_File();


%% Make Visible
set(handles.Summary_panel,'Visible','on');
set(handles.text13,'Visible','on');
set(handles.text14,'Visible','on');
set(handles.text15,'Visible','on');
set(handles.text16,'Visible','on');
set(handles.text17,'Visible','on');
set(handles.MinH,'Visible','on');
set(handles.MinW,'Visible','on');
set(handles.MinX,'Visible','on');
set(handles.MaxH,'Visible','on');
set(handles.MaxW,'Visible','on');
set(handles.MaxX,'Visible','on');
set(handles.Simulation_setup,'Visible','on');
set(handles.Totaltime,'Visible','on');
set(handles.text11,'Visible','on');
set(handles.Dt,'Visible','on');
set(handles.text12,'Visible','on');
set(handles.simulation_panel,'Visible','on');
set(handles.Running,'Visible','on');
%% Make Results Invisible
set(handles.panel_Results,'Visible','off');
set(handles.NewSim_Button,'Visible','off');

guidata(hObject, handles);% Update handles structure
end

%% Spawning event getting input data
%% ::::::::::::::::::::::::::::::::::::::::::::::::::::%

function Xi_input_Callback(hObject, ~, handles)
hFluOilGui = getappdata(0,'hFluOilGui');
HECRAS_data=getappdata(hFluOilGui,'inputdata');
HECRAS_time_index=1; %I need to think about what would happen if temp varies with time.TG
Riverinputfile=HECRAS_data.Profiles(HECRAS_time_index).Riverinputfile;
CumlDistance = single(Riverinputfile(:,2));   %Km
Depth = Riverinputfile(:,3);          %m
Q = Riverinputfile(:,4);              %m3/s
Vmag = Riverinputfile(:,5);           %m/
Width = abs(Q./(Vmag.*Depth));               %m

%% Find initial cell
Xi = str2double(get(handles.Xi_input,'String'));
if Xi > CumlDistance(end)*1000
    ed = errordlg('Spawning location is outside the domain, try a smaller value for Xi','Error');
    set(ed, 'WindowStyle', 'modal');
    uiwait(ed);
end
C = find(Xi<CumlDistance*1000,1,'first');
 
%% Update Yi -->Default: place OPAs in the midle of the cell
set(handles.Yi_input,'String',floor(Width(C)*100/2)/100);
guidata(hObject, handles);% Update handles structure
end

%% OPAs Characteristics getting input data
%% ::::::::::::::::::::::::::::::::::::::::::::::::::::%
function popup_EggsChar_Callback(hObject, ~, handles)

% Determine the selected data set.
str = get(handles.popup_EggsChar, 'String');
val = get(handles.popup_EggsChar,'Value');

% Set current data to the selected data set.
switch str{val};
    case 'Use constant OPA settling velocity and critical shear stress'
        set(handles.textPostFert_Time,'Visible',  'off');
        set(handles.PostferT,'Visible',           'off');
        set(handles.textDiameter,'Visible',        'on');
        set(handles.ConstD,'Visible',              'on');
		set(handles.textVs,'Visible',              'on');
        set(handles.ConstVs,'Visible',             'on');
        set(handles.textDensity,'Visible',         'on');
        set(handles.text_at,'Visible',             'off');
        set(handles.Tref,'Visible',                'off');
        set(handles.text_C,'Visible',              'off');
        set(handles.ConstTauc,'Visible',           'on');
    case 'OPA kinematics (not activated)'
        set(handles.textDiameter,'Visible',       'off');
        set(handles.ConstD,'Visible',             'off');
        set(handles.textDensity,'Visible',        'off');
        set(handles.text_at,'Visible',            'off');
        set(handles.Tref,'Visible',               'off');
        set(handles.text_C,'Visible',             'off');
        set(handles.ConstTauc,'Visible',          'off');
end
guidata(hObject,handles)
end

%% Running the model::::::::::::::::::::::::::::::::::::::::::::::::::::::%

function Running
hFluOilGui=getappdata(0,'hFluOilGui');
handles= getappdata(hFluOilGui, 'handlesmain');
hObject=getappdata(hFluOilGui,   'hObjectmain');
eventdata=getappdata(hFluOilGui,   'eventdatamain');
Running_Callback(hObject, eventdata, handles);
end

function Running_Callback(hObject, eventdata, handles)

%% Get data from Handles
%==========================================================================
handles.userdata.Larvae=get(handles.Larvae,'Checked');
handles.userdata.Num_Eggs=str2double(get(handles.Num_Eggs,'String'));
handles.userdata.Xi=str2double(get(handles.Xi_input,'String'));
handles.userdata.Yi=str2double(get(handles.Yi_input,'String'));
handles.userdata.Zi=str2double(get(handles.Zi_input,'String'));
handles.userdata.Dt=str2double(get(handles.Dt,'String'));
handles.userdata.Totaltime=str2double(get(handles.Totaltime,'String'));

%This is to check Dt for stability
CheckDt = 0;

%% Get data from main GUI
%==========================================================================

%% Check if we are in Batch mode - If batch simulation is checked under
%  the tool drop down menu in the main GUI, activate the Batch Run GUI
%  when the Run Simulation button is pressed. (Updated 2/28/2017 LJ & TG)
Batchmode=get(handles.Batch,'Checked');
if strcmp(Batchmode,'on')
    ed=batchgui();
    uiwait(ed);
    hFluOilGui = getappdata(0,'hFluOilGui');
    inputdata=getappdata(hFluOilGui,'inputdata');
    continuee=inputdata.Batch.continuee;
    NumSim=inputdata.Batch.NumSim;
end

hFluOilGui=getappdata(0,'hFluOilGui');

% user errors
if length(get(handles.edit_River_name, 'String'))<2
    ed = errordlg('Please input the river name','Error');
    set(ed, 'WindowStyle', 'modal');
    uiwait(ed);
    return
end
if isnan(handles.userdata.Num_Eggs)||isnan(handles.userdata.Xi)||isnan(handles.userdata.Yi)||isnan(handles.userdata.Zi)||isnan(handles.userdata.Dt)||isnan(handles.userdata.Totaltime)
    msgbox('Empty input field. Please make sure all required fields are filled out correctly ','FluOil Error: Empty fields','error');
    return
end
if handles.userdata.Num_Eggs<0||handles.userdata.Xi<0||handles.userdata.Yi<0||handles.userdata.Dt<0||any(handles.userdata.Totaltime<0)
    msgbox('Incorrect negative value. Please make sure all required fields are filled out correctly ','FluOil Error: Incorrect negative value','error');
    return
end

if handles.userdata.Zi>0
    msgbox('Incorrect input value. Water surface is located at Zi=0, Zi must be equal or less than zero.','FluOil Error: Incorrect input value','error');
    return
end


%% Batch Run
% --> Right now the batch run only has the capability to run a batch
% simulation for one set of inputs. The number of simulations is read from
% the batch GUI. (Updated 2/28/2017 LJ & TG)

if strcmp(Batchmode,'on')
    
    for k=1:NumSim
        handles.userdata.RunNumber = k;
        
%%ZZ If there is a batch input file, use information from the file
        if size(inputdata.Batch.Batchinputfile_hdr) == [1 10] % If there is a batch input file
            handles.userdata.Num_Eggs=inputdata.Batch.Batchinputfile(k,5);
            handles.userdata.Xi=inputdata.Batch.Batchinputfile(k,2);
            handles.userdata.Zi=inputdata.Batch.Batchinputfile(k,4);
            handles.userdata.Totaltime=inputdata.Batch.Batchinputfile(k,7);
			handles.userdata.Vs=inputdata.Batch.Batchinputfile(k,9);
			handles.userdata.Tauc=inputdata.Batch.Batchinputfile(k,10);			
            
            if inputdata.Batch.Batchinputfile(k,3) > 0 % If Yi is known. 
                handles.userdata.Yi=inputdata.Batch.Batchinputfile(k,3);
            else % Otherwise, use the middle of the cross section
                try
                    HECRAS_time_index=inputdata.HECRASspawiningTimeIndex; %if HEC-RAS unsteady
                catch
                    HECRAS_time_index=1; %if steady state using .xls.
                end
                Riverinputfile=inputdata.Profiles(HECRAS_time_index).Riverinputfile;
                C = find(handles.userdata.Xi<single(Riverinputfile(:,2))*1000,1,'first');
                Width = abs(Riverinputfile(:,4)./(Riverinputfile(:,5).*Riverinputfile(:,3))); %Q/(Vmag*Depth)
                handles.userdata.Yi=floor(Width(C)*100/2)/100;
            end
        end
%%===========================================================================
        
        if k==1
            [minDt,CheckDt,Exit] = FluOilgui(hObject, eventdata,handles,CheckDt);
            %% Checking Dt
            if handles.userdata.Dt>minDt  % If we exit the running function because Dt is to large, correct Dt
                set(handles.Dt,'String',minDt);
                handles.userdata.Dt = minDt;
                FluOilgui(hObject, eventdata,handles,CheckDt);
            end
        else
            FluOilgui(hObject, eventdata,handles,CheckDt);
        end
    end
    
else
    
    [minDt,CheckDt,Exit]=FluOilgui(hObject, eventdata,handles,CheckDt);
    
    %% Checking Dt for stability
    
    if handles.userdata.Dt>minDt  % If we exit the running function because Dt is to large, correct Dt
        set(handles.Dt,'String',minDt);
        handles.userdata.Dt = minDt;
        FluOilgui(hObject, eventdata,handles,CheckDt);
    end
    
end

%% If simulation time greater than hatching time
if minDt==0
    return
end

try
    if Exit==0
        % Make invisible
        set(handles.Running,'Visible',       'off');
        
        % Make Results Visible
        set(handles.panel_Results,'Visible', 'on');
        set(handles.Results,'Visible',       'on');
        set(handles.NewSim_Button,'Visible', 'on');
        diary off
        
        guidata(handles.FluOil_main, handles); %update handles
    end
catch
    %If there was an error during the simulation (FluOilgui)
    msgbox('An unexpected error occurred, FluOil is going to close','FluOil error','error')
    pause(4)
end
end

%% Analyze the Results::::::::::::::::::::::::::::::::::::::::::::::::::::::%
function Results_Callback(hObject, eventdata, handles)
results();
end

function NewSim_Button_Callback(hObject, ~, handles)
set(handles.Summary_panel,'Visible',    'off');
set(handles.Simulation_setup,'Visible', 'off');
set(handles.simulation_panel,'Visible', 'off');
set(handles.panel_Results,'Visible',    'off');
set(handles.Results,'Visible',          'off');
guidata(hObject, handles);

%% For future implementation
% function Batch_button_Callback(hObject, ~, handles)
% Batch();
% set(handles.Batch_button,'Value',1)
% %display(get(handles.popup_EggsChar,'Value'))
% guidata(hObject, handles);
end

% --------------------------------------------------------------------
function Analyze_Results_CreateFcn(hObject, eventdata, handles)
results();
end

% --------------------------------------------------------------------
function Analyze_Results_Callback(hObject, eventdata, handles)
results();
end

% Hatching time -----------------------------------------------------------
function Ht_Callback(hObject, eventdata, handles)
hFluOilGui = getappdata(0,'hFluOilGui');
HECRAS_data=getappdata(hFluOilGui,'inputdata');
HECRAS_time_index=1; %I need to think about what would happen if temp varies with time.TG
Riverinputfile=HECRAS_data.Profiles(HECRAS_time_index).Riverinputfile;

CumlDistance = single(Riverinputfile(:,2));   %Km
Temp = single(Riverinputfile(:,9));          %C
%% Before unsteady         
% Temp = load('./Temp/temp_variables.mat');
% CumlDistance = single(Temp.temp_variables.CumlDistance);
% Temp = single(Temp.temp_variables.Temp);

% Determine where the OPAs %%were spawned
Initial_Cell = find(CumlDistance*1000>=str2double(get(handles.Xi_input,'String')));Initial_Cell=Initial_Cell(1); % Updated TG May,2015

% Determine selected species

if get(handles.Silver,'Value')==1
    specie={'Silver'};
elseif get(handles.Bighead,'Value')==1
    specie={'Bighead'};
else
    specie={'Grass'};
end

TimeToHatch = HatchingTime(Temp(Initial_Cell:end),specie);
msgbox(['The estimated hatching time for an averaged temperature of ',num2str(round(mean(Temp)*10)/10),' C is ', num2str(TimeToHatch), ' hours.'],'FluOil','none');
end

% Goes to website-------------------------------------------------------
function Website_Callback(hObject, eventdata, handles)
diary('./results/FluOil_LogFile.txt')
web('http://asiancarp.illinois.edu/')
end

function settings = FluOil_Settings
settings.version = 'v3.0';
end

% Checks for FluOil updates ---------------------------------------------
function Check_for_updates_Callback(hObject, eventdata, handles)
%% Check FluOil Version
try
    FluOil_Latest_Version=urlread('ftp://ftpext.usgs.gov/pub/er/il/urbana/tgarcia/FluOil_version.txt','Get',{'term','urlread'});
    if strcmpi(FluOil_Latest_Version,handles.settings.version)
        h = msgbox('The FluOil version you are using is up to date, no updates available','Checking for Update..');
    else
        h = msgbox('The FluOil version you are using is out of date, please vistit the FluOil website to download the newest version','Checking for Update..');
    end
    uiwait(h)
catch
    msgbox('error connection failed','FluOil error','error')
end
end
% --------------------------------------------------------------------
function About_FluOil_Callback(~, ~, handles)

% Creates about background figure
set(0,'Units','pixels') ;
scnsize = get(0,'ScreenSize');
About = figure('Name','Percentage of OPAs distributed in the vertical',...
        'Color',[1 1 1],...%[0.9412 0.9412 0.9412],...
        'Name','About FluOil',...
        'position',[scnsize(3)/2 scnsize(4)/2.6 scnsize(3)/3 scnsize(4)/2]);

AboutBackground = axes('Parent',About,'Units','Normalized',...
                  'Position',[0 -0.1 1 1]);

% Displays background
imshow('AboutBackground.png','InitialMagnification','fit');

set(About,'MenuBar','none')
textAbout1 = uicontrol(About,'Style','text','String',...
            {['FluOil ', num2str(handles.settings.version)];'64-bits'},...
            'Units','Normalized','Position',[0.1 0.79 0.8 0.2],'FontSize',14,...
            'BackgroundColor',[1 1 1],'ForegroundColor',[0.039 0.141 0.416]);
textAbout2 = uicontrol(About,'Style','text','String',...
            {'Copyright 2009-2013 University of Illinois at Urbana-Champaign. This program is distributed in the hope that it will be useful,but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.'},...
            'Units','Normalized','Position',[0 0.68 1 0.15],'FontSize',6,...
            'BackgroundColor',[1 1 1]);
end
        
%% Set simulation time to a given developmental stage ===============================
function set_to_stage_button_notused_Callback(hObject, eventdata, handles)

%% Eggs biological properties
if get(handles.Silver,'Value')==1
    specie = {'Silver'};
elseif get(handles.Bighead,'Value')==1
    specie = {'Bighead'};
else
    specie = {'Grass'};
end

%%=========================================================================
Larvaemode = get(handles.Larvae,'Checked');

hFluOilGui = getappdata(0,'hFluOilGui');
HECRAS_data=getappdata(hFluOilGui,'inputdata');
try
HECRAS_time_index=HECRAS_data.HECRASspawiningTimeIndex; %I need to think about what would happen if temp varies with time.TG
catch
    HECRASspawiningTimeIndex=1; %if steady state using .xls.
    HECRAS_time_index=1; %if steady state using .xls.
end
Riverinputfile=HECRAS_data.Profiles(HECRAS_time_index).Riverinputfile;
CumlDistance = single(Riverinputfile(:,2));   %Km
Temp = single(Riverinputfile(:,9));          %C
%% Before unsteady         
% Temp = load('./Temp/temp_variables.mat');
% CumlDistance = single(Temp.temp_variables.CumlDistance);
% Temp = single(Temp.temp_variables.Temp);

Initial_Cell = find(CumlDistance*1000>=str2double(get(handles.Xi_input,...
    'String')),1,'first');
Initial_Cell=Initial_Cell(1); % Updated TG May,2015

%ZZ No larvaemode for OPAs
T2_Gas_bladder = 0;

% switch Larvaemode %:Updated TG May,2015
    % %======================================================================
    % case 'on'
        % if strcmp(specie,'Silver')%if specie=='Silver'
            % Tmin2 = 13.3;%C
            % MeanCTU_Gas_bladder = 1084.59;
            % %STD=97.04;
        % elseif strcmp(specie,'Bighead')
            % Tmin2 = 13.4;%C
            % MeanCTU_Gas_bladder = 1161.07;
            % %STD=79.72;
        % else %case Grass Carp :
            % Tmin2 = 13.3;%C
            % MeanCTU_Gas_bladder = 1100.82;
            % %STD=49.853;
        % end
        % T2_Gas_bladder = single(str2double(num2str(round(MeanCTU_Gas_bladder*...
                        % 10/(mean(Temp(Initial_Cell:end))-Tmin2))/10)));%h
        % handles.userdata.Max_Sim_Time = T2_Gas_bladder;
        % set(handles.Totaltime,'String',handles.userdata.Max_Sim_Time);
        % %======================================================================
    % case 'off'
        % handles.userdata.Max_Sim_Time = HatchingTime(mean(Temp(Initial_Cell:end)),specie);
        % set(handles.Totaltime,'String',handles.userdata.Max_Sim_Time);
        % %======================================================================
% end
Totaltime_Callback(hObject, eventdata, handles)
guidata(hObject, handles);
end

%% Turn ON or OFF larvae drift ============================================
function Larvae_Callback(hObject, eventdata, handles)

Larvaemode=get(handles.Larvae,'Checked');

switch Larvaemode %:Updated TG May,2015
    %======================================================================
    case 'on' %If its set on, that means the user wants to turn it off.
        set(handles.Larvae, 'Checked','off')
        set(handles.set_to_stage_button_notused,'String','Set to hatching time');
    case 'off'
        set(handles.Larvae, 'Checked','on')
        set(handles.set_to_stage_button_notused,'String','Set to time to reach Gas bladder');
end
handles.userdata.Larvae=get(handles.Larvae,'Checked');
end
%======================================================================

function Mortality_model_Callback(hObject, eventdata, handles)
end


function edit_Starting_Date_Callback(hObject, eventdata, handles)
% hObject    handle to edit_Starting_Date (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_Starting_Date as text
%        str2double(get(hObject,'String')) returns contents of edit_Starting_Date as a double
end

% --- Executes during object creation, after setting all properties.
function edit_Starting_Date_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_Starting_Date (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function edit_Starting_time_Callback(hObject, eventdata, handles)
%% If user modifies spawning time
hFluOilGui = getappdata(0,'hFluOilGui');
HECRAS_data=getappdata(hFluOilGui,'inputdata');

SpawningTime=[get(handles.edit_Starting_Date,'String'),' ',get(hObject,'String')];
SpawningTime=strjoin(SpawningTime);
SpawningTime=datenum(SpawningTime,'ddmmyyyy HHMM');
date=arrayfun(@(x) datenum(x.Date,'ddmmyyyy HHMM'), HECRAS_data.Profiles);
HECRASspawiningTimeIndex=find(date<=SpawningTime,1,'last');%use the previous time with available hydraulic data;

 %Display Ending time in main GUI
        endSimtime=SpawningTime+str2double(get(handles.Totaltime,'String'))/24;
        endSimtime_Str=datestr(endSimtime,'ddmmmyyyy HHMM');
        dateandtime = strsplit(char(endSimtime_Str),' ');
        set(handles.edit_Ending_Date,'String',dateandtime(1));
        set(handles.edit_Ending_time,'String',dateandtime(2));
        
HECRAS_data.HECRASspawiningTimeIndex=HECRASspawiningTimeIndex;
setappdata(hFluOilGui,'inputdata',HECRAS_data)
%datestr(date(HECRASspawiningTimeIndex)); For debuggin
end


function edit_Ending_Date_Callback(hObject, eventdata, handles)
% hObject    handle to edit_Ending_Date (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_Ending_Date as text
%        str2double(get(hObject,'String')) returns contents of edit_Ending_Date as a double
end

function edit_Ending_time_Callback(hObject, eventdata, handles)
%% If user modifies spawning time
hFluOilGui = getappdata(0,'hFluOilGui');
HECRAS_data=getappdata(hFluOilGui,'inputdata');

%ZZ
SpawningTime=[get(handles.edit_Starting_Date,'String'),' ',get(handles.edit_Starting_time,'String')];
SpawningTime=strjoin(SpawningTime);
SpawningTime=datenum(SpawningTime,'ddmmyyyy HHMM');
%ZZ-end

endSimtime=[get(handles.edit_Ending_Date,'String'),' ',get(hObject,'String')];
endSimtime=strjoin(endSimtime);
endSimtime=datenum(endSimtime,'ddmmyyyy HHMM');
date=arrayfun(@(x) datenum(x.Date,'ddmmyyyy HHMM'), HECRAS_data.Profiles);
%datestr(endSimtime); For debuggin
EndSimTimeIndex=find(date>=endSimtime,1,'first');

%ZZ: HECRAS_data.SpawningTime might be changed manually in 4. Simulation setup/Starting date and time 
% Totaltime=24*(endSimtime-HECRAS_data.SpawningTime);
Totaltime=24*(endSimtime-SpawningTime);

%If end simulation time is greater than hydraulic data records
if date(end)<endSimtime
    ed = errordlg('The simulated time in HEC-RAS is not long enough to support FluOil simulations, Please extend your simulated period in HEC-RAS. ','Error');
    set(ed, 'WindowStyle', 'modal');
    uiwait(ed);
end
HECRAS_data.EndSimTimeIndex=EndSimTimeIndex;
setappdata(hFluOilGui,'inputdata',HECRAS_data)
set(handles.Totaltime,'String',Totaltime);  
end

% --- Executes during object creation, after setting all properties.
function edit_Ending_time_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_Ending_time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end



function Totaltime_Callback(hObject, eventdata, handles)
try
hFluOilGui = getappdata(0,'hFluOilGui');
HECRAS_data=getappdata(hFluOilGui, 'inputdata');

%ZZ
SpawningTime=[get(handles.edit_Starting_Date,'String'),' ',get(handles.edit_Starting_time,'String')];
SpawningTime=strjoin(SpawningTime);
SpawningTime=datenum(SpawningTime,'ddmmyyyy HHMM');
%ZZ-end

    %ZZ: HECRAS_data.SpawningTime might be changed manually in 4. Simulation setup/Starting date and time 
    %endSimtime=HECRAS_data.SpawningTime+str2double(get(handles.Totaltime,'String'))/24;
    
    if strcmp(get(handles.Inverse_modeling,'Checked'),'off') %ZZ: if NOT inverse modeling   
        endSimtime=SpawningTime+str2double(get(handles.Totaltime,'String'))/24;
    else %ZZ: if inverse modeling, endSimtime is prior to startSimtime. Not useful for computation but only for GUI
        endSimtime=SpawningTime-str2double(get(handles.Totaltime,'String'))/24;
    end
        
    endSimtime=datestr(endSimtime,'ddmmmyyyy HHMM');
    dateandtime = strsplit(char(endSimtime),' ');
    set(handles.edit_Ending_Date,'String',dateandtime(1));
    set(handles.edit_Ending_time,'String',dateandtime(2));
catch
    %steady state or xls.
end
%         %% Assume user want to simulate same time as HEC-RAS
%         Time_day_H_min_sec=datestr(date(end)-date(1),'dd HH MM SS');
%         Time_day_H_min_sec=str2double(strsplit(Time_day_H_min_sec,' '));
%         SimTime_H=(Time_day_H_min_sec(1)*24)+(Time_day_H_min_sec(2))+(Time_day_H_min_sec(3)/60)+(Time_day_H_min_sec(4)/3600);
%         set(handlesmain.Totaltime,'String',SimTime_H);
%         HECRAS_data.simtime_h=SimTime_H;

 
end



% --------------------------------------------------------------------
function Inverse_modeling_Callback(hObject, eventdata, handles)
%% Enables Inverse modeling. If this option is selected, eggs would move backwards:Updated TG May,2015
Inv_mod_status=get(handles.Inverse_modeling,'Checked');
switch Inv_mod_status
    %======================================================================
    case 'on' %If its set on, that means the user wants to turn it off.
        set(handles.Inverse_modeling, 'Checked','off')
        set(handles.Spawning_location_text,'String','Spawning Location (m)')
    case 'off' % If this is off, that means the user it is going to turn it on.
        set(handles.Inverse_modeling, 'Checked','on')
        set(handles.Spawning_location_text,'String','OPAs'' initial location (m)');
end
%handles.userdata.Inv_mod_status=get(handles.Larvae,'Checked');
guidata(hObject, handles);
end


% --------------------------------------------------------------------
function Batch_Callback(hObject, eventdata, handles)
%% Sees if Batch Simulation option is checked in the main GUI
Batchmode=get(handles.Batch,'Checked');

switch Batchmode %:Updated TG & LJ 2/28/2017
    %======================================================================
    case 'on' %If its set on, that means the user wants to turn it off.
        set(handles.Batch, 'Checked','off')
    case 'off'
        set(handles.Batch, 'Checked','on')
end
end


% --- Executes during object creation, after setting all properties.
function popupDiffusivity_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupDiffusivity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


% --- Executes on selection change in popupDiffusivity.
function popupDiffusivity_Callback(hObject, eventdata, handles)
% hObject    handle to popupDiffusivity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupDiffusivity contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupDiffusivity


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over popupDiffusivity.
end

function popupDiffusivity_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to popupDiffusivity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
end

% --- Executes on key press with focus on popupDiffusivity and none of its controls.
function popupDiffusivity_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to popupDiffusivity (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
end

% --- Executes during object creation, after setting all properties.
function Xi_input_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Xi_input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

% --- Executes during object creation, after setting all properties.
function Yi_input_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Yi_input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


% --- Executes during object creation, after setting all properties.
function Zi_input_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Zi_input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end