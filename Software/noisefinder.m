function [Noise_avg,Noise_std]=noisefinder(Bkg,video,i_start,Signal_avg,X1,X2,Y1,Y2,l)

if l>100
    frame=single(255-(rgb2gray(read(video,i_start)))-(Bkg));
else
    frame=single(rgb2gray(read(video,i_start))-Bkg);
end
% get Noise Average and STD

BW=imbinarize(frame,Signal_avg/8);
BW1 = true(size(BW));
BW2 = (BW1-BW);
BW2=imerode(BW2,strel('disk',10));
CurrFrame=frame.*BW2;
Noise=CurrFrame(Y1+30:Y2-30,X1+30:X2-30);
[d1, d2]=size(Noise);
noisedata=double(reshape(Noise,d1*d2,1));
Noise_avg=mean(noisedata);
Noise_std=std(noisedata);
end
