function [label_output]=graphSegmentation(W,K)
N_cp=K-1;
Maxiter=10;
N_cp_now=0;
N=size(W,1);
CP=[];
% split firstly
while N_cp_now<N_cp
    ind=splitFunc(CP',W);
    CP=[CP ind];
    CP=sort(CP);
    N_cp_now=N_cp_now+1;
end
CP=CP';
%% merge and split
iter=0;
while iter<Maxiter
    iter=iter+1;
    fprintf("Iteration %d\n",iter)
    cp_out=mergeFunc(W,CP);
    if sum(abs(cp_out-CP))==0
        break;
    else
        CP=cp_out;
    end
end
[label_output]=CP2Label(cp_out,size(W,1));
function [L_pred]=CP2Label(CP,N)
K=length(CP)+1;
P_out2=sort(CP);
P_out2=reshape(P_out2,[],1);
P_out2=[0;P_out2;N];
L_pred=zeros(N,1);
for k=1+1:K+1
    L_pred(P_out2(k-1)+1:P_out2(k))=k-1;
end
end
function cp=mergeFunc(W,cp)
K=length(cp)+1;
for k=1:K-1
    cp_tild=cp;
    cp_tild(k)=[];
    ind=splitFunc(cp_tild,W);
    if ind~=cp(k)
        cp(k)=ind;
    end
end
    cp=sort(cp);
end
function ind=splitFunc(cp,W)
N_=size(W,1);
K=length(cp)+2;
va=zeros(N_-1,1);
for i=1:N_-1
    CP_=[cp;i];
    CP_=unique(CP_);
    if length(CP_)==length(cp)% 去掉重复
        va(i)=nan;
        continue;
    end
    CP_=sort(CP_);
    CP_=[0;CP_;N_];
    for k=1:K
        if CP_(k)<CP_(k+1)
            Wk=W(CP_(k)+1:CP_(k+1),CP_(k)+1:CP_(k+1));
            
            Wk2=W(CP_(k)+1:CP_(k+1),:);
        end
        va(i)=va(i)+sum(Wk(:))/sum(Wk2(:));
    end
end
[~,ind]=max(va);
end
end