function dataout=tukeyfilter(data, Nx, Px, Ny, Py, Nz, Pz)
%Nx number of point to window to dimension x
%Px number of point of slope to dimension x
%Ny number of point to window to dimension y
%Py number of point of slope to dimension y
%Nz number of point to window to dimension z
%Pz number of point of slope to dimension z

stampa=0;
[M,N,T]=size(data);

if nargin < 4
    %1-D filter
    if (Nx<2*Px)
        disp('Error: Nx<2Px');
    else
        if (N==1)&(T==1)
            if stampa==1 disp('1-D tukey filter'); end
            dataout=ones(M,N);
            dataout = rawfilter(dataout,Nx,Px);
        end
    end
    if stampa==1
        t=1:M;
        plot(t,dataout);
    end
end %end nargin

if (nargin >3) & (nargin < 6)
    %2-D filter
    if (Nx<2*Px) | (Ny<2*Py) 
        disp('Error: Nx<2Px or Ny<2Py');
    else
        if (T==1)
            if stampa==1 disp('2-D tukey filter'); end
            dataout=ones(M,N);
            for i=1:M
                dataout(i,:) = rawfilter(dataout(i,:),Nx,Px);
            end
            for j=1:N
                dataout(:,j) = rawfilter(dataout(:,j),Ny,Py);
            end
        end
    end
    dataout = dataout';
    if stampa==1
        figure name 'XY 2D image, X_ordinate, Y_ascisse'
        imshow(dataout,[0, 1]);
        figure name 'Surf'
        surf(dataout);
        t=1:M;
        figure name 'assi a metà'
        subplot(1,3,1)
        plot(t,dataout(:,N/2));
        title('Direzione X (Y/2,Z/2)');
        subplot(1,3,2)
        plot(t,dataout(M/2,:));
        title('Direzione Y (X/2,Z/2)');
        subplot(1,3,3)
        plot(t,dataout(:,N/2),t,dataout(M/2,:));
        legend('Direzione_X','Direzione_Y');
    end
end

if (nargin >5) & (nargin < 8)
    %3-D filter
    if (Nx<2*Px) | (Ny<2*Py) | (Nz<2*Pz)
        disp('Error: Nx<2Px or Ny<2Py or Nz<2Pz');
    else  
        if stampa==1 disp('3-D tukey filter'); end
        dataout=ones(M,N,T);
        for k=1:T
            for i=1:M
                dataout(i,:,k) = rawfilter(dataout(i,:,k),Nx,Px);
            end
            for j=1:N
                dataout(:,j,k) = rawfilter(dataout(:,j,k),Ny,Py);
            end
            dataout(:,:,k)=dataout(:,:,k)';
        end
        for i=1:M
            for j=1:N
                dataout(i,j,:) = rawfilter(dataout(i,j,:),Nz,Pz);
            end
        end
    end
    if stampa==1
        figure name 'XY 2D image, Y_ordinate, X_ascisse'
        dec = T/16; %define spacing, 16 possible 2D plot
        i=1;
        for k=1:dec:T
            subplot(4,4,i)
            idstr=num2str(k);
            stringa = strcat('slice at z=',idstr);
            imshow(dataout(:,:,k),[0, 1]);
            title(stringa);
            i=i+1;
        end
        figure name 'YZ 2D image, Z_ordinate, Y_ascisse'
        dec = T/16; %define spacing, 16 possible 2D plot
        ii=1;
        for i=1:dec:M
            subplot(4,4,ii)
            idstr=num2str(i);
            stringa = strcat('slice at x=',idstr);
            app=zeros(N,T);
            for j=1:N
                for k=1:T
                    app(j,k)=dataout(i,j,k);
                end
            end
            imshow(app',[0, 1]);
            title(stringa);
            ii=ii+1;
        end
        t=1:M;
        zetapp=zeros(T);
        for k=1:T
            zetapp(k)=dataout(M/2,N/2,k);
        end
        figure name 'assi a metà'
        subplot(2,2,1)
        plot(t,dataout(:,N/2,T/2));
        title('Direzione X (Y/2,Z/2)');
        subplot(2,2,2)
        plot(t,dataout(M/2,:,T/2));
        title('Direzione Y (X/2,Z/2)');
        subplot(2,2,3)
        plot(t,zetapp);
        title('Direzione Z (X/2,Y/2)');
        subplot(2,2,4)
        plot(t,dataout(:,N/2,T/2),t,dataout(M/2,:,T/2),t,zetapp);
        legend('Direzione_X','Direzione_Y','Direzione_Z');
    end
    
end
end
