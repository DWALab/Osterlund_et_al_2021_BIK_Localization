function fret = ClaculateFRET(lifetime, unbound_lifetime)

 fret = ones(size(lifetime)) - (lifetime./unbound_lifetime);
 fret(fret < 0 ) = 0 ; 
 fret(fret > 1) =  1; 
 fret = fret * 100; 
 


end