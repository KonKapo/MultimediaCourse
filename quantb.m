function bc = quantb(b)
DLB = [0.2 0.5 0.8];
if (b<=DLB(1))
    bc=0;
elseif (DLB(1)<b && b<=DLB(2))
    bc=1;
elseif(DLB(2)<b && b<=DLB(3))
    bc=2;
elseif(DLB(3)<b)
    bc=3;
end
end

