function [data, label]=load_YaleBExtend_192_168(from_index,to_index)
%48*42   192*168  缩小了4倍
% max is 38
load('YaleBExtend_192_168.mat');
K=size(X,2);
label=[];
data=[];
for k=1:K
   Xk=X{k};
   data=[data Xk];
   lab=ones(64,1)*k;
   label=[label;lab];
end
data=data';

data=data(label<=to_index,:);
label=label(label<=to_index );
data=data(label>=from_index,:);
label=label( label>=from_index);
%% 选出部分难的
% KK=[2 3 4 5 7 8 9 10 11 12 13 14 15 16 17 18 20 27 28 29 34];
% for k=1:size(KK,2)
%     Xk=squeeze(Y(:,:,k))';
%     X{k}=Xk;
%     Ycell{k}=ones(Num,1);
%     data=[data;Xk];
%     label=[label;ones(Num,1)*k];
% end

end


% function [data, label, Xcell ,Ycell]=get_dataset_YaleB(Nk)
% % max is 38
% load('/Users/xingzheng/Desktop/work_new_year/Clustering/Dataset_all/YaleB_COIL_ORL/YaleBExtend_192_168.mat');
% [~,K,~]=size(X);
% if Nk>K
%     Nk=K;
% end
% 
% 
% data=[];
% label=[];
% Xcell=cell(K,1);
% Ycell=cell(K,1);
% 
% %%
% for k=1:Nk
%     Xk=X{k};
%     Xk=mat2gray(Xk);
%     Num=size(Xk,2);
%     data=[data;Xk'];
%     label=[label;ones(Num,1)*k];
% end
% end