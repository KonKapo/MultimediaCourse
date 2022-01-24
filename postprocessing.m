function sro = postprocessing(s_r)
beta = 28180* (2^-15);        % Preemphasis
sro = zeros(length(s_r),1);
sro(1)=s_r(1);
for k = 2:length(s_r)
    sro(k)=s_r(k) + beta*sro(k-1);
end

end

