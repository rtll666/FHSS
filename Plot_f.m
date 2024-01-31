function Plot_f( SignalFSK ,fs)    
nfft=fs+1;                      % 计算FFT的点数
Y = fft(SignalFSK,nfft);        % 对信号进行FFT
PSignalFSK = Y.* conj(Y)/nfft;  % 计算信号的功率谱密度
f = fs*(0:nfft/2)/nfft;         % 计算频率轴
plot(f,PSignalFSK(1:nfft/2+1)); % 绘制频谱图
xlabel('frequency (Hz)');       % x轴标签
axis([0 10000 -inf inf]);       % 设置坐标轴范围
end

