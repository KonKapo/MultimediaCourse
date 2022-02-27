function [FrmBitStrm, CurrFrmResd] = RPE_frame_coder(s0,PrevFrmResd)
  [LARc,Nc,bc,CurrFrmExFull,CurrFrmSTResd]  = RPE_frame_SLT_coder(s0, PrevFrmResd)
  
  H = [-134 -374 0 2054 5471 8192 5471 2054 0 -374 -134]; 
  H = H / 2^13;
  x = zeros(160,1);
  Mc = zeros(4,1);
  for j = 0:3
    xm = zeros(4,1);
    for k = 1:40
      for i = 1:11
        if(k+6-i>40 | k+6-i<1)
        x(k)+=0;
      else
        x(k+40*j) += H(i)*CurrFrmSTResd(40*j+k+6-i);
      end
    end
  end
  for l = 1:4
    xm(l)=sum(x(l+40*j:3:40*j+40-4+l).^2)
  end
  [~, Mc(j+1)] = max(xm);
  xmax = max(abs(xm((Mc(j+1)+40*j:3:40*j+40-4+Mc(j+1));
  if(xmax>=0 & xmax<=511)
  x_max = floor((xmax)/32);
  elseif(xmax>=512 & xmax<=1023)
  x_maxc = floor((xmax-511)/64)+15;
  elseif(xmax>=1024& xmax<=2047)
  x_maxc = floor((xmax-1023)/128)+23;
  elseif(xmax>=2048& xmax<=4095)
  x_maxc = floor((xmax-2023)/256)+31;    
  elseif(xmax>=4096& xmax<=8191)
  x_maxc = floor((xmax-4095)/512)+39;
  elseif(xmax>=8192& xmax<=16383)
  x_maxc = floor((xmax-8191)/1024)+47;    
  elseif(xmax>=16384& xmax<=32767)
  x_maxc = floor((xmax-16383)/2048)+55;   
end

FrmBitStrm=0;
end
