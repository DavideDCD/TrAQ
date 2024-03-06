function [Signal_avg,Signal_max]=ratfinder(Bkg,video,i_start,nFrames_tot,l)
Signal_avg=zeros(1,10);
Signal_max=zeros(1,10);
Erosion=1;

for i=1:10
    if l>100
        % find the rat and get Signal Average
        frame1=(255-(rgb2gray(read(video,randi([i_start,nFrames_tot])))))-(Bkg);
        frame2=(255-(rgb2gray(read(video,randi([i_start,nFrames_tot])))))-(Bkg);
    else
        frame1=(rgb2gray(read(video,randi([i_start,nFrames_tot]))))-Bkg;
        frame2=(rgb2gray(read(video,randi([i_start,nFrames_tot]))))-Bkg;
    end
    BW = edge(abs(frame1-frame2),'Prewitt');
    BW2 = imdilate(BW,strel('disk',5));
    BW2 = imfill(BW2,'holes');
    BW2 = imerode(BW2,strel('disk',10));
    BW2 = imdilate(BW2,strel('disk',5));
    [~,~,~,~,~,~,~,~,~,~,~,pixellist,~]=getcoordinates(BW2,10,Erosion);
    allids = vertcat(pixellist);
    ind = sub2ind(size(BW), allids(:,2), allids(:,1));
    BW1 = uint8(zeros(size(BW)));
    BW1(ind) = 1;
    CurrFrame=double(frame1.*BW1);
    [d1, d2]=size(CurrFrame);
    CurrFrame(~CurrFrame)=NaN;
    CurrFrame=reshape(CurrFrame,d1*d2,1);
    Signal_avg(i)=nanmean(CurrFrame);
    Signal_max(i)=max(max(CurrFrame));
end
Signal_avg=mean(Signal_avg);
Signal_max=max(Signal_max);
end