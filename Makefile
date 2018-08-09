
# phonies
all: stanfit/stanfit-normal-regression.rds stanfit/stanfit-hoc-regression.rds

# simulate fake data
data/sim-hoc-data.csv data/sim-hoc-data.rds: R/sim-hoc-data.R
	Rscript $<
	
# fit normal regression 
stanfit/stanfit-normal-regression.rds loo/loo-normal-regression.rds ppd/ppd-normal-regression.png: R/fit-normal-regression.R stan/normal-regression.stan data/sim-hoc-data.rds
	Rscript $<
	
# fit hoc regression 
stanfit/stanfit-hoc-regression.rds loo/loo-hoc-regression.rds ppd/ppd-hoc-regression.png: R/fit-hoc-regression.R stan/hoc-regression.stan data/sim-hoc-data.rds
	Rscript $<	
	
# cleaning phonies
cleanALL:
	rm -f data/sim-hoc-data.csv data/sim-hoc-data.rds
	rm -f stanfit/* loo/* ppd/*
	rm -f stan/normal-regression.rds
	rm -f stan/hoc-regression.rds
	
