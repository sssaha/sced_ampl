clc;
clear;
close all;

data= xlsread('branch.xlsx');

% z=zeros(16,16);
% z(1,2)=0.0001 +1i*	0.0001;
% z(2,3)= 0.00375 + 1i* 0.0125;
% z(3,4) = 0.00375 + 1i*0.0125;
% z(4,5) = 0.00375 +1i* 0.0125;
% z(5,6) = 0.00375 +1i* 0.0125;
% z(3,7) = 0.004375 +1i* 0.021875;
% z(1,8) = 0.00875  + 1i* 0.033125;
% z(1,9) = 0.0005 +1i*0.0075;
% z(9,10) = 0.010625 +1i*0.015;
% z(10,11) = 0.005625 +1i* 0.02125;
% z(11,12) = 0.005625 +1i* 0.02125;
% z(9,13) = 0.005625 +1i*0.010625;
% z(13,14) = 0.005625 +1i*0.010625;
% z(10,15) = 0.00625 +1i* 0.023125;
% z(15,16) = 0.00625 +1i* 0.023125;

bus= max(max(data(:,2:3)));
y= zeros(bus,bus);

[r c]=size(data);

for i = 1:r
    val = 1i*data (i,4) +  data (i,5);
    val = 1/val;
    row = data(i,2);
    col = data(i,3);
    y(row,col)=-val;
    y(col,row)=-val;
    
end

for i= 1 : bus
    y(i,i) = -sum(y(i,:));
end
y=y(1:16,1:16);


z= inv(y);


mini=[];
val=0;
for i=1:bus-1
    for c = 1:bus-1
        val = val + (abs(z(i,c)))^2;
    end
    mini = [mini (sqrt(val))];
    val=0;
end
znorm=0.25/max(mini)
%%
y=[y ;zeros(1,16)];
y=[y (zeros(1,17))'];

fileID = fopen('Yimag.dat','w');
fprintf(fileID,'%s','param yimag:');
fprintf(fileID,'%d\t',1:17);
fprintf(fileID,'%s\n',':=');
for i = 1:17
    fprintf(fileID,'%d\t',i);
    fprintf(fileID,'%1.3f\t',imag(y(i,:)));
    if (i~=17)
        fprintf(fileID,'%s\n','');
   else
       fprintf(fileID,'%s',';');
   end
end
fclose(fileID);


fileID = fopen('Yreal.dat','w');
fprintf(fileID,'%s','param yreal:');
fprintf(fileID,'%d\t',1:17);
fprintf(fileID,'%s\n',':=');
for i = 1:17
    fprintf(fileID,'%d\t',i);
    fprintf(fileID,'%1.3f\t',real(y(i,:)));
    if (i~=17)
        fprintf(fileID,'%s\n','');
    else
%         fprintf(fileID,'%d\t',i);
%         fprintf(fileID,'%1.3f\t',zeros(1,17));
        fprintf(fileID,'%s',';');
   end
end
fclose(fileID);

z=[z ;zeros(1,16)];
z=[z (zeros(1,17))'];

fileID = fopen('Zreal.dat','w');
fprintf(fileID,'%s','param zreal:');
fprintf(fileID,'%d\t',1:17);
fprintf(fileID,'%s\n',':=');
for i = 1:17
    fprintf(fileID,'%d\t',i);
    fprintf(fileID,'%1.3f\t',real(z(i,:)));
    if (i~=17)
        fprintf(fileID,'%s\n','');
   else
       fprintf(fileID,'%s',';');
   end
end
fclose(fileID);

fileID = fopen('Zimag.dat','w');
fprintf(fileID,'%s','param zimag:');
fprintf(fileID,'%d\t',1:17);
fprintf(fileID,'%s\n',':=');
for i = 1:17
    fprintf(fileID,'%d\t',i);
    fprintf(fileID,'%1.3f\t',imag(z(i,:)));
    if (i~=17)
        fprintf(fileID,'%s\n','');
   else
       fprintf(fileID,'%s',';');
   end
end
fclose(fileID);
%%
sg=0;
for i = 1:16
   frompos =  find(data(:,2)==i);
   topos = find(data(:,3)==i);
   sg= sg+(sum(data(frompos,6)/1800+data(topos,6)/1800))^2; % To derate the line by 10% and dividing by 100 to convert to per unit
end
sg
%%
y=zeros(5,5);
base = (64+1.4*1i) * (10^(-6));
y(1,5)= -1/(base*1200);
y(1,2)= -1/(base*1200);
y(2,3) = -1/(base*1800);
y(4,5) = -1/(base*1800);
y(3,4) = -1/(base*900);

y(5,1)= -1/(base*1200);
y(2,1)= -1/(base*1200);
y(3,2)= -1/(base*1800);
y(5,4)= -1/(base*1800);
y(4,3)= -1/(base*900);

for i= 1 : 5
    y(i,i) = -sum(y(i,:));
end
y=y(1:4,1:4);
z=inv(y);
val=0;
for i=1:4
    for c = 1:4
        val = val + (abs(z(i,c)))^2;
    end
    disp(sqrt(val))
    val=0;
end


fileID = fopen('.dat','w');


