function [ price ]=cost4single(Single,City)
Product=struct(...
'Base',250,...                            % 每车固定成本250元/辆
'km_price',3,...                          % 运输成本3元/km
'Load_Max',9,...                          % 车辆最大载重量9t
'Speed',45,...                            % 车速45km/h
'Unit',4000,...                           % 单位产品价值4000元/t
'Cold_Move_Minu',0.05,...                 % 运输过程中单位时间制冷成本0.05元/分钟
'Cold_Dicharge_Minu',0.1,...              % 卸货过程中单位时间制冷成本0.1元/分钟
'A1',0.002,...
'A2',0.003,...
'Gas4Move',0.225,...                      % 冷藏运输车单位距离油耗22.5L/100km
'Gas4Cold',0.0025,...                     % 制冷设备单位重量货物的单位时间的能源消耗量0.0025L/t*km
'CarbonIndex',1.052,...                   % 碳排放系数1.052kg/L
'CarbonPrice',0.13326);                   % 碳税价格0.13326元/kg*CO2

%%
%route=max(find(Single.table_load));%通过route计算会因为最后一个城市刚好送完而产生bug
route=max(find(Single.table))-1;
C=zeros(1,5);
%% C1
C(1)=Product.Base;
%% C2
d=zeros(1,route);
for i=1:route
    d(i)=City.Distance(Single.table(i),Single.table(i+1));
end
C(2)=sum(d.*Single.table_load(1:route));
%% C3
% 货损=到达所花的时间*该地点所需货物量+卸货时间*离开该地点所需货物量
% 到达所花的时间=每地点卸货时间+路程时间，到1城为0

flag=find(Single.table==1);%为1的标志位
period=length(flag);%断开来
D=[];
for i=1:period-1
    temp{i}=cumsum(d(flag(i):(flag(i+1)-1)));
    D=[D temp{i}];%从原点出发到达各处距离
end
T1=D/Product.Speed+Single.sevice_time(1:route)/60;%各城市到达时间
for i=1:route
    if Single.table_load(i+1)==9
        nd(i)=Single.table_load(i)-Single.table_load(i+1)+9;
    else nd(i)=Single.table_load(i)-Single.table_load(i+1);
    end
end
c31=sum(nd.*(1-exp(-Product.A1*(T1))));
% 卸货时间=需求量/装载量*服务时间
T2=Single.sevice_time(1:route)/60;
c32=sum(Single.table_load(1:route).*(1-exp(-Product.A2*(T2))));
C(3)=Product.Unit*(c31+c32);
%% C4
% 运输制冷
for i=1:route
    if Single.table_load(i+1)==0
        d_cold(i)=0;
    else d_cold(i)=d(i);
    end
end
c41=sum(d_cold/Product.Speed*Product.Cold_Move_Minu);
% 卸货制冷
c42=sum(Single.sevice_time(1:route)*Product.Cold_Dicharge_Minu);
C(4)=c41+c42;
%% C5
% 时间

c51=sum(d_cold/Product.Speed.*Single.table_load(1:route));
% 距离
c52=Product.Gas4Move*sum(d_cold);
C(5)=Product.CarbonIndex*Product.CarbonPrice*(c51+c52);
%% 
price=sum(C);
end

