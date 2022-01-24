function s = preprocessing(frame)
% Performs Offset Compensation and Preemphasis
alpha = 32735*2^-15;        % Offset compensation 3.1.1
beta = 28180* 2^-15;        % Preemphasis         3.1.2
s=zeros(length(frame),1);
s0f=zeros(length(frame),1);
s0f(1)=frame(1);
s(1)=s0f(1);
for k = 2:length(frame)
    s0f(k)=frame(k)-frame(k-1)+alpha*s0f(k-1);
    s(k)=s0f(k)-beta*s0f(k-1);
end
end

