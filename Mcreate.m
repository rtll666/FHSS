%生成一个伪随机序列
function seq = Mcreate(prim_poly) % 将本原多项式转换为二进制
connections=de2bi(prim_poly);
N=length(connections);            % 计算connections的长度
tmp1=fliplr(connections);         % 反转connections
con=tmp1(2:N);                    % 去掉反转后的第一个元素
m=length(connections)-1;          % 计算m       
L=2^m-1;                          % 计算L                 
registers=[zeros(1,m-1) 1];       % 初始化registers数组  
seq(1)=registers(m);              % 将registers的最后一个元素存储到seq中      
for ii=1:L                        % 循环L次，生成伪随机序列
seq(ii)=registers(m);             % 将registers的最后一个元素存储到seq中
tmp2=registers*con';              % 计算LFSR的结果
tmp2=mod(tmp2,2);                 % 对结果进行取模，得到0或1
registers(2:m)=registers(1:m-1);  % 将registers数组向右移动一位   
registers(1)=tmp2;                % 将计算结果存储到registers的第一个元素中
end; 
end

