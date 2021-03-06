reset;
set BUS;
set BRANCH;
set GENS;
#set LOAD;
set SEGMENTS = 1..4 by 1;

param Nv default card (SEGMENTS);


param N default 17;
set SLACK = {N};
param V_slack_real default 1; # slack bus real voltage 1 per unit
param V_slack_im default 0;

#branch data
param branch_fbus  			{BRANCH};
param branch_tbus  			{BRANCH};
param branch_z_real     	{BRANCH};
param branch_z_im			{BRANCH};
param branch_limit_real		{BRANCH};
param branch_limit_im		{BRANCH};
param branch_limit 			{BRANCH};
param branch_r				{BRANCH};
param branch_x				{BRANCH};
param branch_real_seg		{BRANCH};
param branch_im_seg 		{BRANCH};

param 	gen_bus 				{GENS};
param	gen_Pmin 				{GENS};
param	gen_Pmax				{GENS};
param	gen_b					{GENS};
param	gen_c					{GENS};
param	gen_startCost			{GENS};
param 	gen_minUp	   			{GENS};
param 	gen_minDn	   			{GENS};


param bus_load  {BUS};

var P_gen	{GENS};
var Q_gen	{GENS};

var Vr {n in BUS};
var Vi {n in BUS};

var P_inj {n in BUS};
var Q_inj {n in BUS};


var Irsq 	{BRANCH};
var Iisq 	{BRANCH};
var Ir 		{BRANCH};
var Ii 		{BRANCH};

param grid default 1;
var psb binary;
param tie_limit default 50;
param utility_purchase {BUS} >=0;
param utility_sell {BUS} >=0;


# theta Constraints
param V_max default 1.1;
param V_min default 0.9;
param theta_max default (3.1416/3); # 60 Degree and -60 Degree
param theta_min default (-3.1416/3);
param grid_price default 1.2;

param sin_theta_max default sin(theta_max);
param sin_theta_min default sin(theta_min);
param cos_theta_max default cos(theta_max);
param cos_theta_min default cos(theta_min);
param tan_theta_max default tan(theta_max);
param tan_theta_min default tan(theta_min);
param sec_theta_dif default (1/cos(0.5*(theta_max-theta_min)));


param yreal {n in BUS, n in BUS};
param yimag {n in BUS, n in BUS};

param zreal {n in BUS, n in BUS};
param zimag {n in BUS, n in BUS};

param power_factor default 0.95;
param tan_power_factor default tan (acos(power_factor));

minimize totalcost : sum {g in GENS} (P_gen[g] *  gen_b[g]) + sum {n in BUS} (utility_purchase[n]*1.2* grid_price-utility_sell[n]* grid_price) 

# Equation 4 to 6
subj to Voltage_real {n in (BUS diff SLACK)}: 
	Vr[n] = Vr[N]  + 1/Vi[N] * (sum {np in BUS, k in BRANCH : np <> N and branch_fbus[k] = n and branch_tbus[k]=np} (branch_z_real[k] * P_inj[n] + branch_z_im[k] * Q_inj[n]));


subj to Voltage_imaginary {n in (BUS diff SLACK)}:
	Vi[n] = Vi[N]  + 1/Vi[N] * (sum {np in BUS, k in BRANCH : np <> N and branch_fbus[k] = n and branch_tbus[k]=np} (branch_z_im[k] * P_inj[n] - branch_z_real[k] * Q_inj[n]));

subj to Voltage_real_slack {n in BUS : n = N} :
	Vr[n] = V_slack_real;

subj to Voltage_im_slack {n in BUS : n = N} :
	Vi[n] = V_slack_im;


#putting the voltage constraints; equation 21 to 24

subj to edge_1 {n in (BUS diff SLACK)} :
	Vi[n] <= (sin_theta_max - sin_theta_min) / (cos_theta_max - cos_theta_min) * (Vr[n]-V_min* sec_theta_dif * cos_theta_min ) + V_min * sec_theta_dif * sin_theta_min;

subj to edge_2 {n in (BUS diff SLACK)} :
	Vi[n] <= sin_theta_max / (cos_theta_max-1) * (Vr[n]- V_max);

subj to edge_3	{n in (BUS diff SLACK)} :
	Vi[n] <= -sin_theta_min / (cos_theta_min-1) * (Vr[n]- V_min);

subj to edge_4_5 {n in (BUS diff SLACK)} :
	tan_theta_min * Vr[n] <= Vi[n] <= tan_theta_max * Vr[n] ;


# Equation 11 and 12
subj to Total_Real_Power_Loss :
		sum {n in BUS} P_inj[n] = 0.5  *  sum {k in BRNACH} (branch_r[k] * (Irsq[k] + Iisq[k]));

subj to Total_Reactive_Power_Loss :
		 sum {n in BUS} Q_inj[n] = 0.5  *  sum {k in BRNACH} (branch_x[k] * (Irsq[k] + Iisq[k]));


# Equation 13 to 20
subj to Cable_Current_constraint_Real {k in BRANCH}:
		Ir[k] = -Yr [branch_fbus[k],branch_tbus[k]] * (Vr[branch_fbus[k] - Vr[branch_tbus[k]) +
				 Yi [branch_fbus[k],branch_tbus[k]] * (Vi[branch_fbus[k] - Vi[branch_tbus[k]);

subj to Cable_Current_constraint_Imaginary {k in BRANCH}:
		Ii[k] = -Yi [branch_fbus[k],branch_tbus[k]] * (Vr[branch_fbus[k] - Vr[branch_tbus[k]) -
				 Yr [branch_fbus[k],branch_tbus[k]] * (Vi[branch_fbus[k] - Vi[branch_tbus[k]);

subj to Square_real_limit_1 {k in BRANCH, v in SEGMENTS}:
		Irsq[k] >= (v*branch_real_seg[k])*(v*branch_real_seg[k]) + (2*v-1)*branch_real_seg[k]* (Ir[k] - v*branch_real_seg[k]);

subj to Square_real_limit_2 {k in BRANCH, v in SEGMENTS}:
				Irsq[k] >= (v*branch_real_seg[k])*(v*branch_real_seg[k]) - (2*v-1)*branch_real_seg[k]* (Ir[k] + v*branch_real_seg[k]);

subj to Square_imaginary_limit_1 {k in BRANCH, v in SEGMENTS}:
						Iisq[k] >= (v*branch_im_seg[k])*(v*branch_im_seg[k]) + (2*v-1)*branch_im_seg[k]* (Ii[k] - v*branch_im_seg[k]);

subj to Square_imaginary_limit_2 {k in BRANCH, v in SEGMENTS}:
						Iisq[k] >= (v*branch_im_seg[k])*(v*branch_im_seg[k]) - (2*v-1)*branch_im_seg[k]* (Ii[k] + v*branch_im_seg[k]);

subj to branch_real_seg_limit {k in BRANCH}:
							branch_real_seg[k] = branch_limit_real[k]/Nv;

subj to branch_imaginary_seg_limit {k in BRANCH}:
							branch_im_seg[k] = branch_limit_im[k]/Nv;							
						
subj to Total_Current_Limit {k in BRANCH}:
									 	Irsq[k] + Iisq [k] <= branch_limit[k] ;

# Export and Import constraints; equations 36-38
subj to utility_purchase_const {n in BUS}:
			n <> N ==> utility_purchase[n] = 0 else utility_purchase[n] <= grid * tie_limit * psb ;
subj to utility_sell_constraint {n in BUS} :
			n <> N ==> utility_sell[n] = 0 else utility_sell[n] <= grid * tie_limit * (1-psb);

# Node balance equation
subj to RealPower_node_balance {n in BUS} :
			P_inj[n] = utility_purchase[n] - utility_sell[n] +  (sum{g in GENS: gen_bus[g] == n} P_gen[g]) - bus_load [n] ;
subj to ReactivePower_node_balance {n in (BUS diff SLACK)} :
		    Q_inj[n] = P_inj [n] * tan_power_factor ;


# Generation Limit
subj to GenLimit {g in GENS} :
		 gen_Pmin[g] <= P_gen[g] <= gen_Pmax [g] ;
		 
data;

param: BUS : bus_load := include LoadData.dat;
param: GENS: gen_bus gen_Pmin gen_Pmax gen_b gen_c gen_startCost gen_minUp gen_minDn := include mgGenData.dat;
param: BRANCH: branch_fbus branch_tbus branch_z_im branch_z_real branch_rateA branch_rateC := include mgbranchData.dat;

data Yreal.dat;
data Yimag.dat;
data Zreal.dat;
data Zimag.dat;

