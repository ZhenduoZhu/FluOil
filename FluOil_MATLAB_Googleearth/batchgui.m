function varargout = batchgui(varargin)
% BATCHGUI MATLAB code for batchgui.fig
%      BATCHGUI, by itself, creates a new BATCHGUI or raises the existing
%      singleton*.
%
%      H = BATCHGUI returns the handle to a new BATCHGUI or the handle to
%      the existing singleton*.
%
%      BATCHGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BATCHGUI.M with the given input arguments.
%
%      BATCHGUI('Property','Value',...) creates a new BATCHGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before batchgui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to batchgui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help batchgui

% Last Modified by GUIDE v2.5 25-Apr-2017 18:10:26

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @batchgui_OpeningFcn, ...
                   'gui_OutputFcn',  @batchgui_OutputFcn, ...
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
% End initialization code - DO NOT EDIT
end

% --- Executes just before batchgui is made visible.
function batchgui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to batchgui (see VARARGIN)

% Choose default command line output for batchgui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes batchgui wait for user response (see UIRESUME)
% uiwait(handles.figure1);
end

% --- Outputs from this function are returned to the command line.
function varargout = batchgui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
end


function NumSim_Callback(hObject, eventdata, handles)
% hObject    handle to NumSim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of NumSim as text
%        str2double(get(hObject,'String')) returns contents of NumSim as a double
end


% --- Executes on button press in BatchrunButton.
function BatchrunButton_Callback(hObject, eventdata, handles)
hFluOilGui = getappdata(0,'hFluOilGui');
inputdata=getappdata(hFluOilGui,'inputdata');
inputdata.Batch.NumSim=str2double(get(handles.NumSim,'String'));
inputdata.Batch.continuee=1;
setappdata(hFluOilGui,'inputdata',inputdata)
close(handles.figure1)%Close GUI
end

function BatchrunButton_CreateFcn(hObject, eventdata, handles)
end

%ZZ --- Executes on button press in "Load Batch Simulation Data".
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%%::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
hFluOilGui = getappdata(0,'hFluOilGui');
inputdata = getappdata(hFluOilGui,'inputdata');

[FileName,PathName]=uigetfile({'*.*',  'All Files (*.*)';
    '*.xls;*.xlsx'     , 'Microsoft Excel Files (*.xls,*.xlsx)'; ...
    '*.csv'             , 'CSV - comma delimited (*.csv)'; ...
    '*.txt'             , 'Text (Tab Delimited (*.txt)'}, ...
    'Select file to import');
strFilename = fullfile(PathName,FileName);

if PathName == 0 %if the user pressed cancelled, then we exit this callback
    return
else
    if FileName ~= 0
        % Load Batch run input file which includes information of multiple
        % OPAs
        m = msgbox('Please wait, loading file...','FluOil');
        extension=regexp(FileName, '\.', 'split');
        if (strcmp(extension(end),'xls') == 1 || strcmp(extension(end),'xlsx') == 1)
            %% If xlsread fails
            try %Eddited TGB 03/21/14
                [Batchinputfile, Batchinputfile_hdr] = xlsread(strFilename);
                close(m);
            catch
                close(m);
                m = msgbox('Unexpected error, please try again','FluOil error','error');
                uiwait(m)
                return
            end
            %%
        elseif strcmp(extension(end),'csv') == 1
            Batchinputfile = importdata(strFilename);
            Batchinputfile_hdr = Batchinputfile.textdata;
            Batchinputfile = Batchinputfile.data;
            close(m);
        elseif strcmp(extension(end),'txt') == 1
            Batchinputfile = importdata(strFilename);
            if  isstruct(Batchinputfile)
                Batchinputfile_hdr = Batchinputfile.textdata;
                Batchinputfile_hdr = regexp(Batchinputfile_hdr, '\t', 'split');
                Batchinputfile_hdr = Batchinputfile_hdr{1,1};
                Batchinputfile = Batchinputfile.data;
            else
                ed = errordlg('Please fill all the data required in the Batch input file, and load the file again','Error');
                set(ed, 'WindowStyle', 'modal');
                uiwait(ed);
                close(m)
                return
            end
            close(m)
            %%
        else
            msgbox('The file extension is unrecognized, please select another file','FluOil Error','Error');
            return
        end %Checking file extension
        try
            handles.userdata.Batchinputfile = Batchinputfile(:,10);
            handles.userdata.Batchinputfile_hdr = Batchinputfile_hdr(:,1:10);
            if size(Batchinputfile_hdr) ~= [1 10]
                ed = msgbox('Incorrect Batch input file, please select another file','FluOil Error','Error');
                set(ed, 'WindowStyle', 'modal');
                uiwait(ed);
                return
            elseif sum(strcmp(Batchinputfile_hdr(:,1:10),{'Egg_ID','StartingX_m','StartingY_m','StartingZ_m','Num_OPAs','StartingTime','SimulationTime_hr','Temp_C','Vs_mm/s','Tauc_Pa'}))<10 %YL add Vs and Tauc in input file in batchmode
                ed = msgbox('Incorrect Batch input file, please select another file','FluOil Error','Error');
                set(ed, 'WindowStyle', 'modal');
                uiwait(ed);
                return
            end
            set(handles.Batchinputfile,'Data',handles.userdata.Batchinputfile(:,1:10));
            Batchin_DataPlot(handles);
        catch
            if size(Batchinputfile,2) ~= 10
                ed = errordlg('Please fill all the data required in the Batch input file, and load the file again','Error');
                set(ed, 'WindowStyle', 'modal');
                uiwait(ed);
                return
            end
        end %try
        set(handles.NumSim,'String',size(Batchinputfile,1)); %ZZ set total number of simulation according to input file
        inputdata.Batch.NumSim=str2double(get(handles.NumSim,'String'));
    end
end %if user pres cancel
%%
%% Save data in hFluOilGui
inputdata.Batch.Batchinputfile=Batchinputfile;
inputdata.Batch.Batchinputfile_hdr=Batchinputfile_hdr;
setappdata(hFluOilGui, 'inputdata',inputdata);

guidata(hObject, handles);% Update handles structure
end
