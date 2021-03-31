function fret = CalculateFRET(lifetime, unbound_lifetime)

 fret = ones(size(lifetime)) - (lifetime./unbound_lifetime);

 fret(fret > 1) =  1; 
 fret = fret * 100; 
 


end