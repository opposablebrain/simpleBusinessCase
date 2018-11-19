clear;clc

%Input data range
nRange=100;
massGrossRange=linspace(1000,5000,nRange);  %Gross takeoff mass evaluation range [kg]
vCruiseRange=linspace(10,110,nRange);       %Cruise speed evaluation range [m/s]

[M,V]=meshgrid(massGrossRange,vCruiseRange); M=M'; V=V';
pilot=0;
nPax=2:5;
unit=ones(numel(M),1);
%Battery data
cellType='c';
specificHullCost=440*2.2;

switch lower(cellType)
    case 'a' %Advanced cells
        specificBatteryCost=660/3600/1000;
        cellSpecificEnergy=325*3600;
        cycleLifeFactor=315;
    case 'b' %Basic cells
        specificBatteryCost=250/3600/1000;
        cellSpecificEnergy=240*3600;
        cycleLifeFactor=315;
    case 'c' %Advanced cells (at scale)
        specificBatteryCost=125/3600/1000;
        cellSpecificEnergy=325*3600;
        cycleLifeFactor=630;
end
inputs={'specificBatteryCost',specificBatteryCost,'cellSpecificEnergy',cellSpecificEnergy,'pilot',pilot,'specificHullCost',specificHullCost,'cycleLifeFactor',cycleLifeFactor};

for i=1:length(nPax)
    [P,R,T,L,C]=simpleBusinessCase(M(:),V(:),nPax(i),inputs{:},'out',{'profitPerYear';'range';'costPerFlightHour';'lod';'cycleLife'});
    
    P=reshape(P,nRange,nRange)/1e6;
    R=reshape(R,nRange,nRange)/1e3;
    T=reshape(T,nRange,nRange);
    L=reshape(L,nRange,nRange);
    C=reshape(C,nRange,nRange);
    
    %Plot results
    if numel(R)>4
        %Plot contours of ticket price, GTOW, and profitability
        figure(1);
        if i==1; clf; end
        subplot(1,length(nPax),i); hold on;
        contour(V*3.6,R,C,'linewidth',2,'ShowText','on','linecolor',[0.9 0.9 1])
        contour(V*3.6,R,P,'linewidth',2,'ShowText','on')
        xlabel('Cruise speed [km/h]')
        ylabel('Range [km]')
        ylim([0 100])
        
        title({'Annual profit per vehicle [$M]';[num2str(nPax(i),'%0.0f') ' pax + ' num2str(pilot,'%0.0f') ' pilot']})
        grid on
        
        %Keep color mapping the same between all figures
        if i==1
            clim=[min(min(P)) max(max(P))];
        else
            clim(1)=min(min(min(P)),clim(1));
            clim(2)=max(max(max(P)),clim(2));
        end
    end
end

%Harmonize plot colors
if numel(R)>4
    for i=1:length(nPax)
        figure(1);
        subplot(1,length(nPax),i);
        caxis(clim)
        colormap(parula)
    end
end