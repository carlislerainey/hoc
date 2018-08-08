
# phonies
all: stanfit/stanfit-normal-regression.rds

# simulate fake data
data/sim-hoc-data.csv data/sim-hoc-data.rds: R/sim-hoc-data.R
	Rscript $<
	
# fit linear regression 
stanfit/stanfit-normal-regression.rds: R/normal-regression.R stan/normal-regression.stan data/sim-hoc-data.rds
	Rscript $<
	
# cleaning phonies
cleanALL:
	rm -f data/sim-hoc-data.csv data/sim-hoc-data.rds
	rm -f stanfit/*
	rm -f stan/normal-regression.rds
