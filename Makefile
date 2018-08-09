
# phonies
all: loo/looic.png dag

# draw makefile dag
dag: makefile-dag.png
makefile-dag.png: Makefile
	make -Bnd | make2graph | dot -Tpng -Gdpi=300 -o makefile-dag.png

# simulate fake data
data/sim-hoc-data.csv data/sim-hoc-data.rds: R/sim-hoc-data.R
	Rscript $<
	
# fit normal regression 
stanfit/stanfit-normal-regression.rds loo/loo-normal-regression.rds ppd/ppd-normal-regression.png: R/fit-normal-regression.R stan/normal-regression.stan data/sim-hoc-data.rds
	Rscript $<

# fit heteroskedastic student's t regression 
stanfit/stanfit-het-students-t-regression.rds loo/loo-het-students-t-regression.rds ppd/ppd-het-students-t-regression.png: R/fit-het-students-t-regression.R stan/het-students-t-regression.stan data/sim-hoc-data.rds
	Rscript $<	
	
# fit hoc regression 
stanfit/stanfit-hoc-regression.rds loo/loo-hoc-regression.rds ppd/ppd-hoc-regression.png: R/fit-hoc-regression.R stan/hoc-regression.stan data/sim-hoc-data.rds
	Rscript $<	
	
# compare fits
loo/looic.png: R/compare-fits.R loo/loo-normal-regression.rds loo/loo-het-students-t-regression.rds loo/loo-hoc-regression.rds
	Rscript $<		

# cleaning phonies
cleanALL:
	rm -f data/sim-hoc-data.csv data/sim-hoc-data.rds
	rm -f stanfit/* loo/* ppd/*
	rm -f stan/normal-regression.rds
	rm -f stan/het-students-t-regression.rds
	rm -f stan/hoc-regression.rds
	
