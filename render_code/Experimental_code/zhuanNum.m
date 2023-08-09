%% *********************************************************************
% Copyright (C) 2022, MCNC of hust.
%
 
% 这个代码用于均匀抽取图片，比如原来是50张图片，按照2倍抽取，得到25张图片
% *********************************************************************

clear all
close all 
clc



cd('data\statue120\');
 
filesNanes = dir('*.jpg');
c1_index = 0;
c2_index = 0;
j=0;

jiange=8;  % 抽取间隔，可以按照自己需要设置，比如2倍，3倍均匀抽取，都可以

for i = 1:jiange:size(filesNanes,1)
    Img_modified{i} = imread(filesNanes(i).name); 
    j=j+1;
    ccc{j}=imresize(Img_modified{i},[240,320]);         %把ai转成240x320的大小   
    
    % 以下是存储路径,注意根据自己电脑路径修改
    if 100<j 
        imwrite(ccc{j},['F:\graduate\EXPERIMENT\viewRenderCode\viewRenderCode\data\statue15\statue0',num2str(j-1),'.jpg']); 
    elseif (10<j)&&(j<101)        
        imwrite(ccc{j},['F:\graduate\EXPERIMENT\viewRenderCode\viewRenderCode\data\statue15\statue00',num2str(j-1),'.jpg']); 
    else
         imwrite(ccc{j},['F:\graduate\EXPERIMENT\viewRenderCode\viewRenderCode\data\statue15\statue000',num2str(j-1),'.jpg']);
    end 
end





















