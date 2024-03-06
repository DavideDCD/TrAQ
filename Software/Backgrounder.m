function [Bkg]=Backgrounder(video,vidHeight,vidWidth,i_start,i_end,color_space)

if 	strcmp(color_space,'grays')==1
    color = 4;
elseif strcmp(color_space,'red')==1
    color = 1;
elseif strcmp(color_space,'green')==1
    color = 2;
elseif strcmp(color_space,'blue')==1
    color = 3;
end

Matrix_Histo=int16(zeros(vidHeight*vidWidth,256) );
tic
for i = 1:100
    if color ==4
        frame=reshape(rgb2gray(read(video,randi([i_start,i_end]))),[],1);
    else
            frame=(read(video,randi([i_start,i_end])));
            frame=frame(:,:,color);
            frame=reshape(frame,[],1);
    end
    for k=1:vidHeight*vidWidth
        a=frame(k)+1;
        Matrix_Histo(k,a)=Matrix_Histo(k,a)+1;
    end
end

[~,Bkg] = max(Matrix_Histo,[],2);
Bkg=uint8(reshape(Bkg,vidHeight,vidWidth)-1);
end
