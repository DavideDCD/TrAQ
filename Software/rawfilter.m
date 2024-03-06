function dataf = rawfilter(dataone,Nn,Pn)
M=length(dataone);
zfil=(M-Nn)/2;
for j=1:Pn
    dataone(j+zfil)=dataone(j+zfil)*0.5*(1-cos((j-1)*pi/Pn));
end
for j=(M-Pn):M
    dataone(j-zfil)=dataone(j-zfil)*0.5*(1+cos((j-M+Pn)*pi/Pn));
end
if (zfil > 0)
    for j=1:zfil
        dataone(j)=0;
    end
    for j=(M-zfil+1):M
        dataone(j)=0;
    end
end
dataf=dataone;
end