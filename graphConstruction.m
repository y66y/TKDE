function [W] = graphConstruction(X, lambda)
[m,n]=size(X);
W=rand(n,n);
Wk=W;
e=ones(n,1);
E=ones(n,n);
rho=0.0;
alpha=0.5;
XtX=X'*X;
tol1=1e-4;
tol2=1e-1;
maxIter=8000;
convergenced=false;
iter=0;
while ~convergenced
    gz=gradient(XtX,W,E,lambda);
    Gamma=max(W-rho*gz,0)-W;
    Wk=W;
    W=W+alpha*Gamma;
    s=reshape(W-Wk,n*n,1);
    gzn=gradient(XtX,W,E,lambda);
    y=reshape(gzn-gz,n*n,1);
    rho=(s'*s)/(s'*y);
    cc1=norm(W-Wk,'fro');
    cc2=rho;
    if cc1<tol1 && cc2<tol2
        convergenced=true;
    end
    if iter>maxIter
        convergenced=true;
    end
    if mod(iter,100)==0 || convergenced
        fprintf(1,'iter is %d, Norm Change is %f, Step Size is %f\n',iter,cc1,cc2);
    end
    iter=iter+1;
end
W=(abs(W)+abs(W)')/2;
W=W-diag(diag(W));

function [g] = gradient(XtX,W,E,lambda)
    g=2*XtX*W-2*XtX+2*lambda*W*E;



