%% *********************************************************************
% Copyright (C) 2022, MCNC of hust.
%
 
% ����������ھ��ȳ�ȡͼƬ������ԭ����50��ͼƬ������2����ȡ���õ�25��ͼƬ
% *********************************************************************

clear all
close all 
clc



cd('data\statue120\');
 
filesNanes = dir('*.jpg');
c1_index = 0;
c2_index = 0;
j=0;

jiange=8;  % ��ȡ��������԰����Լ���Ҫ���ã�����2����3�����ȳ�ȡ��������

for i = 1:jiange:size(filesNanes,1)
    Img_modified{i} = imread(filesNanes(i).name); 
    j=j+1;
    ccc{j}=imresize(Img_modified{i},[240,320]);         %��aiת��240x320�Ĵ�С   
    
    % �����Ǵ洢·��,ע������Լ�����·���޸�
    if 100<j 
        imwrite(ccc{j},['F:\graduate\EXPERIMENT\viewRenderCode\viewRenderCode\data\statue15\statue0',num2str(j-1),'.jpg']); 
    elseif (10<j)&&(j<101)        
        imwrite(ccc{j},['F:\graduate\EXPERIMENT\viewRenderCode\viewRenderCode\data\statue15\statue00',num2str(j-1),'.jpg']); 
    else
         imwrite(ccc{j},['F:\graduate\EXPERIMENT\viewRenderCode\viewRenderCode\data\statue15\statue000',num2str(j-1),'.jpg']);
    end 
end





















