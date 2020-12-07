function varargout = PercentageOPAs_location_time(varargin)
% PERCENTAGEOPAS_LOCATION_TIME MATLAB code for PercentageOPAs_location_time.fig
%%:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::%
%%                    Calculate percentage of OPAs at a given             %
%%                             location, depth, and time                  %
%:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::%
%-------------------------------------------------------------------------%
% FluOil tool to calculate percentage of OPAs at a given location, depth  %
% and time. This tool is particulary useful for hindcasting spawning      %
% grounds based on OPAs collected in the field                            %
%-------------------------------------------------------------------------%
%   Created by      : Tatiana Garcia                                      %
%   Last Modified   : October 24, 2016                                    %
%-------------------------------------------------------------------------%
% Copyright 2016 Tatiana Garcia
%:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::%

% Last Modified by GUIDE v2.5 25-Oct-2016 10:57:47

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @PercentageOPAs_location_time_OpeningFcn, ...
    'gui_OutputFcn',  @PercentageOPAs_location_time_OutputFcn, ...
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
end %function
% End initialization code - DO NOT EDIT


function PercentageOPAs_location_time_OpeningFcn(hObject, eventdata, handles, varargin)
%ZZ-12/4/2020 axes(handles.bottom); imshow('asiancarp.png');
%%=========================================================================
% handleResults=getappdata(0,'handleResults');
% ResultsSim=getappdata(handleResults,'ResultsSim');

handles.output = hObject;
guidata(hObject, handles);
end %function

function varargout = PercentageOPAs_location_time_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;
end %function

function [OPA_sampling_location_m,SamplingTime,Sampling_depth_m,SamplingTime_minutes]=load_data_from_GUI(handles)
OPA_sampling_location_m=str2double(get(handles.OPA_sampling_location_m,'String'));
SamplingTime=str2double(get(handles.OPA_sampling_time_hr,'String'));
Sampling_depth_m=str2double(get(handles.Sampling_depth_m,'String'));
SamplingTime_minutes=str2double(get(handles.SamplingTime_minutes,'String'));
end


% --- Executes on button press in calculate_percentage_of_OPAs_button.
function calculate_percentage_of_OPAs_button_Callback(hObject, eventdata, handles)
%The percentage of OPAs is calculated based on OPAs located before the
%bongonet at the starting sampling time. Number of OPAs collected
%corresponds to OPAs that crossed the sampling distance withing the
%sampling time

%% Load results
handleResults=getappdata(0,'handleResults');
ResultsSim=getappdata(handleResults,'ResultsSim');
[OPA_sampling_location_m,SamplingTime,Sampling_depth_m,SamplingTime_minutes]=load_data_from_GUI(handles);
X=ResultsSim.X;
Z=ResultsSim.Z;
time=ResultsSim.time;

 %% Where are all the OPAs when sampling occured?
 TimeIndex_start=find(time<=((SamplingTime*3600)-(SamplingTime_minutes*60/2)),1,'last');
 TimeIndex_end=find(time>=((SamplingTime*3600)+(SamplingTime_minutes*60/2)),1,'first');
if isempty(TimeIndex_end)
    ed=errordlg(['You need to do another simulation with at least ',num2str(SamplingTime_minutes/2),' minutes more of simulation time'],'Error');
    set(ed, 'WindowStyle', 'modal');
    uiwait(ed);
    Exit=1;
    return
end
 X_at_timewindow=X(TimeIndex_start:TimeIndex_end,:);

%  DispersionofOPAsat_sampling=max(X_at_sampling)-min(X_at_sampling);
%  Dx_m=round(2*(DispersionofOPAsat_sampling^(1/3)))/2;

%find OPAs at starting sampling window located before the net in the
%longitudinal direction
OPAsBeforeNetAtSampling=find(( X_at_timewindow(1,:)<=OPA_sampling_location_m));
N=0; %Initialize OPA counter=0
set(handles.Percentage_OPAs,'String',' ')
 for i=1:size(OPAsBeforeNetAtSampling,2) %For all OPAs located before the net at the begining of the sampling period..
     % Find the time at which OPAs crossed the net
     Samplingtimeindex=find(X_at_timewindow(:,OPAsBeforeNetAtSampling(i))>=OPA_sampling_location_m,1,'first');
     if Samplingtimeindex>=1 %If OPA crossed the net
         %OPAIndex(i)=OPAsBeforeNetAtSampling(i);
         %% Find the vertical location of the OPA
         ZOPAAtSampling=Z(TimeIndex_start+Samplingtimeindex,OPAsBeforeNetAtSampling(i));
         %% If located where net was, count it
         if ZOPAAtSampling>=-Sampling_depth_m
                N=N+1;
         end      
    end
 end
 set(handles.Percentage_OPAs,'String', num2str(N*100/size(X,2)))
 ed=errordlg('Done','Check your results');
 set(ed, 'WindowStyle', 'modal');
 uiwait(ed);
end

%If user changes sampling location or OPA age
function OPA_sampling_location_m_Callback(hObject, eventdata, handles)
try  % Try first, because if the user had not finished filling up the blcks we might have an error
 calculate_location_accuracy(handles);
catch
end
end



























% 
% function Generateplot_debuggin(handles)
% figure('color','w')
% plot([OPA_sampling_location_m OPA_sampling_location_m],[5600 5900],'r','linewidth',3)
% hold on
% for i=1:size( X_at_sampling,2)
% plot(X_at_timewindow(:,i),[time(TimeIndex_start):time(2)-time(1):time(TimeIndex_end)],'*g')
% hold all
% end
% %find OPAs at starting sampling window located before the net
% OPAsBeforeNetAtSampling=find(( X_at_timewindow(1,:)<=OPA_sampling_location_m));
% N=0;      
%  for i=1:size(OPAsBeforeNetAtSampling,2)
%      Samplingtimeindex=find(X_at_timewindow(:,OPAsBeforeNetAtSampling(i))>=OPA_sampling_location_m,1,'first');
%      if Samplingtimeindex>=1
%          OPAIndex(i)=OPAsBeforeNetAtSampling(i);
%          ZOPAAtSampling=Z(TimeIndex_start+Samplingtimeindex,OPAsBeforeNetAtSampling(i))
%          if ZOPAAtSampling>=-Sampling_depth_m
%                 N=N+1;
%          end
%          plot(X_at_timewindow(:,OPAsBeforeNetAtSampling(i)),[time(TimeIndex_start):time(2)-time(1):time(TimeIndex_end)],'*k')
%       
%     end
%  end
% end

