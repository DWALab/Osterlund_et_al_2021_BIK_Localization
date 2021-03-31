function [G_f,S_f]  = GetINOPhasor(x)

    freq0 = 30.51757e6;                   % laser frequency, here 80 MHz
   delta_t = 6.4e-11;           % width of one time channel

    harmonic = 1;    
   freq = harmonic * freq0;        % virtual frequency for higher harmonics
    w = 2 * pi * freq ; 
   M=length(x);
   tb_vec = linspace(1,M, M)'; 
    Gn_ma = cos(w * delta_t * (tb_vec - 0.5));
    Sn_ma = sin(w * delta_t * (tb_vec - 0.5));
    
    % calculate data phasor
    Gn = double(x) .* double(Gn_ma) ;  %take decdata from preprocessing
    Sn = double(x) .* double(Sn_ma) ;
    area = sum(x) ;
    
    % normalization
    G_f = sum(Gn) ./ area;
    S_f = sum(Sn) ./ area;


end
