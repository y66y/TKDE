function [W_out,order]=graphPermutation(W,epsilon)
W=mapminmax(-W,0,1);
N=size(W,1);
dist_epsilon=zeros(1,N);
Reachability_dist=ones(1,N)*10^10;
for i=1:N	
    D=sort(W(i,:));
    dist_epsilon(i)=D(epsilon);  
end
order=[];
seeds=1:N;
ind=randi(N);
while ~isempty(seeds)
    ob=seeds(ind);        
    seeds(ind)=[]; 
    order=[order ob];
    Reachability_dist_new=max([ones(1,length(seeds))*dist_epsilon(ob);W(ob,seeds)]);
    ii=(Reachability_dist(seeds))>Reachability_dist_new; 
    Reachability_dist(seeds(ii))=Reachability_dist_new(ii); 
    [~, ind]=min(Reachability_dist(seeds));
end   

W_out=W(order,order);
W_out=mapminmax(-W_out,0,1);
order=order';
end
