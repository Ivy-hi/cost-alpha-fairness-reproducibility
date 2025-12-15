% 假设您已经有了下面的数据：
% T - 信号周期
% d - 各车道的离开率
% a - 各车道的到达率
% tau - 各信号相位的时长，这是一个优化变量
% K - 信号相位的数量
% N - 车辆的数量

% 定义问题的参数
K = 2; % 假设有2个信号相位
J = 4; % 假设一共4个车道
Total_time = 900; % 总考虑时长，15min
d = 0.625; % 各车道的离开率，每秒钟0.5辆车
a = [0.1089 0.0722 0.0767 0.0267]; % 各车道的到达率，每秒钟车辆的数量
q0= [3 3 3 3]; %各车道初始时刻的队伍长度
time_y=3;%黄灯等待时长
% 车道与phase的控制关系(没用到)
lanephase_matrix=eye(2);


%周期内各个车道上新来车总数
allarrival=floor([392 260 276 96]/4);
%构建延迟矩阵

max_time=20;
% 定义目标函数
alpha_set=[0,0.2,0.5,0.7,1,1.5,2,3,5]
%alpha_set=[1];
alpha_matrix=zeros(3,min(size(alpha_set)));

result_matrix=zeros(max_time-time_y,max_time-time_y);

counter=0;

for alpha=alpha_set
    counter=counter+1;
    for m=time_y+1:max_time
        for n=time_y+1:max_time

            delay_matrix=zeros(J,max(allarrival));
            departure_time_matrix=zeros(J,max(allarrival));
            tau=[m n];
            T=sum(tau);
            %计算目标函数值
            delta=[0 cumsum(tau(1:end-1))];
            
            for j=1:J
            
                for i=1:allarrival(j)
    
                     if i==1
                        second_to_leave=(i+q0(j)-1)/d;%离开所需的秒数
                        cycle_to_leave=ceil(second_to_leave/(d*tau(ceil(j/2))) );%第几个周期离开
                        planned_time_to_leave=T*(cycle_to_leave-1)+delta(ceil(j/2))+second_to_leave-tau(ceil(j/2))*(cycle_to_leave-1);%窗口期所对应的时间
                        %窗口时间车有可能还没到
                        arrival_time=1/a(j)*i;
                        if arrival_time>planned_time_to_leave
                            if arrival_time<   T*floor(arrival_time/T)+delta(ceil(j/2))+tau(ceil(j/2))
                                real_time_to_leave=arrival_time;
                            else
                                real_time_to_leave=  T*ceil(arrival_time/T)+delta(ceil(j/2));
                            end
    
                        else
                            real_time_to_leave= planned_time_to_leave;
                        end
                        departure_time_matrix(j,i)=real_time_to_leave;
                        delay_matrix(j,i)=real_time_to_leave-arrival_time;
    
                     end
    
                     if i~=1
                         arrival_time=1/a(j)*i;
                        %判断是否需要排队
                         if  arrival_time>departure_time_matrix(j,i-1) %若不需要排队
                            if arrival_time<   T*floor(arrival_time/T)+delta(ceil(j/2))+tau(ceil(j/2))
                                real_time_to_leave=arrival_time;
                            else
                                real_time_to_leave=    T*ceil(arrival_time/T)+delta(ceil(j/2));
                            end
                         else%若需要排队
                            planned_time_to_leave=departure_time_matrix(j,i-1)+1/d;%最理想情况下的离开时间
                            if planned_time_to_leave<=   T*floor(departure_time_matrix(j,i-1)/T)+delta(ceil(j/2))+tau(ceil(j/2))
                            real_time_to_leave=planned_time_to_leave;
                            else
                            real_time_to_leave=T*ceil(departure_time_matrix(j,i-1)/T)+delta(ceil(j/2));
                            end
                          end
                        
                          departure_time_matrix(j,i)=real_time_to_leave;
                          delay_matrix(j,i)=real_time_to_leave-arrival_time;
    
    
                     end




                
                end
            end
    
        result_matrix(m-time_y,n-time_y)=sum(delay_matrix.^(1+alpha),'all');
    
        end
    
    end

[alpha_matrix(1,counter),alpha_matrix(3,counter)]=min(min(result_matrix))
[~,alpha_matrix(2,counter)]=min(result_matrix(:,alpha_matrix(3,counter)))




end

plot_matrix=zeros(max(size(alpha_set)),sum(allarrival));

for num=1:max(size(alpha_set))

    delay_matrix=zeros(J,max(allarrival));
    departure_matrix=zeros(J,max(allarrival));
    img_car_matrix=zeros(J,max(allarrival));


    tau=alpha_matrix(2:3,num)'+time_y;
    T=sum(tau);
    delta=[0 cumsum(tau(1:end-1))];
    for j=1:J
            
                for i=1:allarrival(j)
    
                     if i==1
                        second_to_leave=(i+q0(j)-1)/d;%离开所需的秒数
                        cycle_to_leave=ceil(second_to_leave/(d*tau(ceil(j/2))) );%第几个周期离开
                        planned_time_to_leave=T*(cycle_to_leave-1)+delta(ceil(j/2))+second_to_leave-tau(ceil(j/2))*(cycle_to_leave-1);%窗口期所对应的时间
                        %窗口时间车有可能还没到
                        arrival_time=1/a(j)*i;
                        if arrival_time>planned_time_to_leave
                            if arrival_time<   T*floor(arrival_time/T)+delta(ceil(j/2))+tau(ceil(j/2))
                                real_time_to_leave=arrival_time;
                            else
                                real_time_to_leave=  T*ceil(arrival_time/T)+delta(ceil(j/2));
                            end
    
                        else
                            real_time_to_leave= planned_time_to_leave;
                        end
                        departure_time_matrix(j,i)=real_time_to_leave;
                        delay_matrix(j,i)=real_time_to_leave-arrival_time;
    
                     end
    
                     if i~=1
                         arrival_time=1/a(j)*i;
                        %判断是否需要排队
                         if  arrival_time>departure_time_matrix(j,i-1) %若不需要排队
                            if arrival_time<   T*floor(arrival_time/T)+delta(ceil(j/2))+tau(ceil(j/2))
                                real_time_to_leave=arrival_time;
                            else
                                real_time_to_leave=    T*ceil(arrival_time/T)+delta(ceil(j/2));
                            end
                         else%若需要排队
                            planned_time_to_leave=departure_time_matrix(j,i-1)+1/d;%最理想情况下的离开时间
                            if planned_time_to_leave<=   T*floor(departure_time_matrix(j,i-1)/T)+delta(ceil(j/2))+tau(ceil(j/2))
                            real_time_to_leave=planned_time_to_leave;
                            else
                            real_time_to_leave=T*ceil(departure_time_matrix(j,i-1)/T)+delta(ceil(j/2));
                            end
                          end
                        
                          departure_time_matrix(j,i)=real_time_to_leave;
                          delay_matrix(j,i)=real_time_to_leave-arrival_time;
    
    
                     end




                
                end
    end
    
    plot_matrix(num,:)=[delay_matrix(1,1:allarrival(1)) delay_matrix(2,1:allarrival(2)) delay_matrix(3,1:allarrival(3)) delay_matrix(4,1:allarrival(4))];
  

end
sum(plot_matrix)
figure()

num_alpha=max(size(alpha_set))
for i=1:num_alpha
subplot(num_alpha,2,2*(i-1)+1)
histogram(plot_matrix(i,:)',[0:0.1:5])
title(num2str(alpha_set(i)))

subplot(num_alpha,2,2*(i-1)+2)
title(num2str(alpha_set(i)))
plot(plot_matrix(i,:)')
end
sum(plot_matrix(:,1:sum([652 372]/4))')
std(plot_matrix(:,1:sum([652 372]/4))')
max(plot_matrix(:,1:sum([652 372]/4))')
figure()
scatter(sum(plot_matrix(:,1:sum([652 372]/4))')/sum(allarrival),max(plot_matrix(:,1:sum([652 372]/4))'))
xlabel("The average delay time (second)")
ylabel("The maximum delay time (second)")