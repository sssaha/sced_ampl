# the data assumes two separate matrices for real and complex value
# the code can be modified to just invert real number
# calcualte the inverse of a matrix of complex numbers
reset;

set SIZE ;

param Real {r in SIZE, c in SIZE};
param Imaginary {r in SIZE, c in SIZE};
param b {SIZE};

var x {SIZE};
var y {SIZE};

minimize number : 0 ;

subject to axb_real {r in SIZE}: 
	sum {c in SIZE} (Real[r,c] * x[c]- Imaginary[r,c] * y[c]) = b[r]; 
	
subject to axb_im {r in SIZE}: 
	sum {c in SIZE} (Real[r,c] * y[c] + Imaginary[r,c] * x[c]) = 0; 

	
data;
param: SIZE: branch_fbus branch_tbus branch_z_im branch_z_real branch_rateA branch_rateC := include mgbranchData.dat;	












