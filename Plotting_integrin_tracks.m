%From TrackMate export the tracks as xml 
xmlfile = uigetfile('*.xml', 'Select an XML file to analyze');
close all;
tracks = importTrackMateTracks(xmlfile);
trackNum = size(tracks,1);
%set track origin to zero cordinates
%zeroTrackX = zeros(size(tracks{1,1}(:,2),1),size(tracks,1));
%zeroTrackY = zeros(size(tracks{1,1}(:,2),1),size(tracks,1));
for i=1:1:trackNum
    trackSize = size(tracks{i,1});
    for j=1:1:trackSize
        zeroTrackX(j,i) = (tracks{i,1}(j,2) - (tracks{i,1}(1,2)));
        zeroTrackY(j,i) = tracks{i,1}(j,3) - (tracks{i,1}(1,3));
    end
end
largestTrack = size(zeroTrackY,1);
for i=1:1:trackNum
    for j=2:1:largestTrack
        if zeroTrackX(j,i) == 0;
            zeroTrackX(j,i) = zeroTrackX(j-1,i);
            zeroTrackY(j,i) = zeroTrackY(j-1,i);
        end
    end
end

figure('ToolBar','none','InvertHardcopy','off','Color',[1 1 1],'Renderer', 'painters', 'Position', [10 10 600 500]);
plot(zeroTrackX,zeroTrackY,'LineWidth',1.5,'Color',[0 0 1])
ax = gca;
ax.XAxisLocation = 'origin';
ax.YAxisLocation = 'origin';
ax.Position = [0 0 1 1];
maxAxis = ceil((max(max((max(abs(zeroTrackX(:,:))))),max((max(abs(zeroTrackY(:,:))))))));
axis([maxAxis*-1,maxAxis,maxAxis*-1,maxAxis])
box(ax,'off');
set(ax,'FontName','helvetica','FontSize',12,'FontWeight','normal','LineWidth',1);
