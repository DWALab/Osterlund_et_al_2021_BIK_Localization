function [x,y,most_frequent]  = GetSwarmSpread(X,Y)
    x = X; 
    y = Y; 
    scale = 0.3; 
     nbins=50;
    [N,edges] = histcounts(y,nbins);
    mode_idx = find(N == max(N));
    most_frequent = median([edges(mode_idx),edges(mode_idx+1)]);
    dis = N / max(N); 
    for k = 2:length(edges)
        i = find(y>=edges(k-1) & y<edges(k));
        mn = -dis(k-1)*scale ; mx = dis(k-1)*scale;
        x(i) = x(i) + (mx-mn).*rand(size(i)) + mn;
        
       
    end
    
    
end


