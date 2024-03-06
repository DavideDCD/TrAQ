function [xhead,yhead,xtail,ytail,area,cc,majoraxis,minoraxis,eccentricity,vertices,eulernumber,pixellist,flag]=getcoordinates(BW,Area_th,Erosion)

markimg = regionprops(logical(BW),'Centroid','Area','PixelList','MajorAxisLength','MinorAxisLength','Eccentricity','ConvexHull','EulerNumber');
[area,maxArea]=max(cat(1, markimg.Area));      % array position of larger Area
if area>Area_th
    flag=1;
    cc=markimg(maxArea).Centroid;
    area =markimg(maxArea).Area; % mass of the centroid
    majoraxis=markimg(maxArea).MajorAxisLength; % Axis lenght
    minoraxis=markimg(maxArea).MinorAxisLength;
    eccentricity=markimg(maxArea).Eccentricity;
    vertices=markimg(maxArea).ConvexHull;
    eulernumber=markimg(maxArea).EulerNumber;
    pixellist=markimg(maxArea).PixelList;
    BW1 = false(size(BW));
    allids = vertcat(markimg(maxArea).PixelList);
    ind = sub2ind(size(BW), allids(:,2), allids(:,1));
    BW1(ind) = 1;
%   BW1= bwmorph(BW1,'skel',Inf);
if Erosion == 0
    % Identify the tail as the farthest point from centroid
    D = bwdistgeodesic(BW1,floor(cc(1)),floor(cc(2)),'quasi-euclidean');
    [~,x] = max(D(:));
    [y,x]=ind2sub(size(D),x);
    xtail = x;
    ytail = y;
    
    % Identify the head as the fartherst point from the tail
    D = bwdistgeodesic(BW1,xtail,ytail,'quasi-euclidean');
    [~,x] = max(D(:));
    [y,x]=ind2sub(size(D),x);
    xhead = x;
    yhead = y;
else
    % Identify the head as the farthest point from centroid
    D = sqrt((pixellist(:,1) - cc(1)).^2 + (pixellist(:,2) - cc(2)).^2);
    [~,x] = max(D(:));
    xhead = pixellist(x,1);
    yhead = pixellist(x,2);
    
    % Identify the tail as the fartherst point from the head
    D = bwdistgeodesic(BW1,xhead,yhead,'quasi-euclidean');
    [~,x] = max(D(:));
    [y,x]=ind2sub(size(D),x);
    xtail = x;
    ytail = y;
end
else
    flag=0;
    cc=[0,0];
    xhead=0;
    yhead=0;
    xtail=0;
    ytail=0;
    area=0;
    majoraxis=0;
    minoraxis=0;
    pixellist=0;
    eccentricity=0;
    vertices=0;
    eulernumber=0;
end
end
