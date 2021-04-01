function h = plotonebox(y,x,w,s)
n = length(y);
    if n < 25
        return

    end
if n==1
   q1 = y;
   q2 = y;
   q3 = y;
else
   y = sort(y);
   t = 0.25*(n+1);
   t0 = floor(t);
   t1 = ceil(t);
   t = t-t0;
   q1 = y(t0)*t + y(t1)*(1-t);
   t = 0.50*(n+1);
   t0 = floor(t);
   t1 = ceil(t);
   t = t-t0;
   q2 = y(t0)*t + y(t1)*(1-t);
   t = 0.75*(n+1);
   t0 = floor(t);
   t1 = ceil(t);
   t = t-t0;
   q3 = y(t0)*t + y(t1)*(1-t);
end
% if outlier
%    iqr = q3-q1;
%    I1 = y < q1-1.5*iqr;
%    I2 = y > q3+1.5*iqr;
%    outliers = y(I1|I2);
%    y(I1|I2) = [];
%    h = [0;0];
% else
%    outliers = [];
%    h = 0;
% end
outliers = []; 
h = 0 ;
q0 = y(1);
q4 = y(end);
w = w/2;
s = (s/2)-w;
l = x-w;
r = x+w;
px = [ l,  r,  r,  l,  l,  NaN, l-s, r+s, NaN ];
py = [ q1, q1, q3, q3, q1, NaN, q2,  q2,  NaN ];
h(1) = line(px,py,'color','black','linestyle','-','linewidth',1,...
            'marker','none');
% if ~isempty(outliers)
%    h(2) = line(repmat(x,size(outliers)),outliers,'parent',axh,'linestyle','none',...
%           'linewidth',1,'marker','.','markeredgecolor','black');
end