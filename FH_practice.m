%生成随机的基带信号源，并绘制信号波形图
clc;clear;
g=40;fs=100000;            %基带信号码元长度g,采样率fs
r=-10;delay=0;             %信噪比r,延迟
sig1=round(rand(1,g));     %产生随机信号源，round函数用于将随机数四舍五入为0或1
signal1=[];                %初始化信号
for k=1:g                  %离散点化     
if sig1(1,k)==0            %遍历每个码元
sig=-ones(1,1000);         %设置1000个样点为-1
else          
sig=ones(1,1000);          %设置1000个样点为1
end      

signal1=[signal1 sig];     %将生成的样点添加到信号中
end  
figure(1)                  %创建图形窗口
plot(signal1,'b','linewidth',1);%绘制信号波形，蓝色线，线宽为1    
grid on;                   %显示网格
axis([-100 1000*g -1.5 1.5]); %设置坐标轴范围
title('信号源')

T0=200; f0=1/T0;           %周期，频率
T1=400; f1=1/T1;           %周期，频率
u0=gensig('sin',T0,1000*g-1,1); %生成正弦波信号u0
u0=rot90(u0);              %旋转信号矩阵
u1=gensig('sin',T1,1000*g-1,1);%生成正弦波信号u1
u1=rot90(u1);              %旋转信号矩阵
y0=u0.*sign(-signal1+1);   %生成调制信号y0
y1=u1.*sign(signal1+1);    %生成调制信号y1
SignalFSK=y0+y1;           %生成的FSK信号 
figure(2);
% subplot(2,1,1);  
plot(SignalFSK)           % FSK信号的时域波形 
axis([-100 1000*g -3 3]); 
title('SignalFSK') 


%生成FSK调制信号，并绘制其时域波形。
t1=(0:100*pi/999:100*pi);            
t2=(0:110*pi/999:110*pi);                 
t3=(0:120*pi/999:120*pi);                            
t4=(0:130*pi/999:130*pi);                   
t5=(0:140*pi/999:140*pi);                
t6=(0:150*pi/999:150*pi);        
t7=(0:160*pi/999:160*pi);   
t8=(0:170*pi/999:170*pi);   
c1=cos(t1);                      
c2=cos(t2);  
c3=cos(t3);                      
c4=cos(t4);
c5=cos(t5);
c6=cos(t6); 
c7=cos(t7); 
c8=cos(t8); 
adr1=Mcreate(1001203);  %1001203
adr1=[adr1,adr1(1),adr1(2)];      %用户地址为初始m序列
fh_seq1= []; 
for k=1:g   
seq_1=adr1(3*k-2)*2^2+adr1(3*k-1)*2+adr1(3*k);   
fh_seq1=[fh_seq1 seq_1];              %生成用户载波序列 
end

spread_signal1=[];           %用户一载波
fhp=[]; 
for k=1:g      
c=fh_seq1(k);     
switch(c)         
case(0)              
spread_signal1=[spread_signal1 c8];         
case(1)              
spread_signal1=[spread_signal1 c1];                %形成随机载频序列         
case(2)              
spread_signal1=[spread_signal1 c2];         
case(3)              
spread_signal1=[spread_signal1 c3];         
case(4)              
spread_signal1=[spread_signal1 c4];         
case(5)                      
spread_signal1=[spread_signal1 c5]; 
case(6)              
spread_signal1=[spread_signal1 c6];         
case(7)              
spread_signal1=[spread_signal1 c7];                
end      
fhp=[fhp (500*c+5000)]; 
end

figure(3) %跳频图案
plot(fhp,'s','markerfacecolor','b','markersize',12); 
grid on;

freq_hopped_sig1=SignalFSK.*spread_signal1;   %跳频扩频调制（类似于幅度调制）
figure(4);  
plot((1:1000*g),freq_hopped_sig1);    %跳频扩频后的时域信号
axis([-100 1000*g -2 2]);  
title('跳频扩频后的时域信号'); 


% 加多径 
s1=freq_hopped_sig1;  
s=[zeros(1,delay) s1(1:(1000*g-delay))]; 
freq_hopped_sig1=freq_hopped_sig1+s;    
% 加高斯白噪声  
awgn_signal=awgn(freq_hopped_sig1,r,1/2);%信噪比为r；

figure(7); 
subplot(2,1,1)  
plot((1:1000*g),awgn_signal);  
title('扩频调制后加高斯白噪声的信号'); 
subplot(2,1,2)  
Plot_f(awgn_signal,fs);  
title('扩频调制后加高斯白噪声的信号频谱'); 

%解跳（相干解调）
receive_signal=awgn_signal.*(spread_signal1);%混频   
figure(8)  
subplot(2,1,1)  
plot([1:1000*g],receive_signal); 
title('混频后的信号'); 
subplot(2,1,2); 
Plot_f(receive_signal,fs); 
title('混频后的频谱'); 

%低通滤波 
cof_band=fir1(64,1000/fs);   
signal_out=filter(cof_band,1,receive_signal);
figure(9)  
subplot(2,1,1) 
plot([1:1000*g],signal_out); 
title('低通滤波后的信号'); 
subplot(2,1,2);  
Plot_f(signal_out,fs);  
title('低通滤波后的频谱');

%解调
[u2,k]=gensig('sin',T0,1000*g-1,1);u2=rot90(u2);   
[u3,k]=gensig('sin',T1,1000*g-1,1);u3=rot90(u3); 
receive_signal0=signal_out.*u2; 
cof_band=fir1(64,600/fs);   
signal_out0=filter(cof_band,1,receive_signal0);   

receive_signal1=signal_out.*u3;%接收的信号即为带有高斯白噪声的信号1 
cof_band=fir1(64,600/fs);  
signal_out1=filter(cof_band,1,receive_signal1);   
uout=signal_out1-signal_out0; 
figure(10); 
subplot(2,1,1)  
plot(k,signal1);
axis([-100 1000*g -1.5 1.5]); 
title('原始信源'); 
subplot(2,1,2)  
plot(k,uout);
axis([-100 1000*g -4 4]); 
title('FSK解调后的信号');

%抽样判决
sentenced_signal=ones(1,g);                 
for n=1:g     
    ut=0;      
for m=(n-1)*1000+1:1:1000*n;          
    ut=ut+uout(m);
end     
    if ut<0          
     sentenced_signal(n)=0;     
    end 
end

sentenced_signal_wave=[];     %输出采样序列波形这里是+1，-1方波
for k=1:g      
    if sentenced_signal(1,k)==0          
        sig=-ones(1,1000);    % 1000 minus ones for bit 0     
    else          
        sig=ones(1,1000);     % 1000 ones for bit 1     
    end      
    sentenced_signal_wave=[sentenced_signal_wave sig]; 
end  
figure(11),subplot(2,1,1) 
plot(signal1);  
axis([-100 1000*g -1.5 1.5]);  
title('信源序列'); 
subplot(2,1,2)  
plot(sentenced_signal_wave); 
axis([-100 1000*g -1.5 1.5]);  
title('还原后的信号序列');  

