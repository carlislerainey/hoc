
# simulate fake data
data/sim-hoc-data.csv data/sim-hoc-data.rds: R/sim-hoc-data.R
	Rscript $<
	
# cleaning phonies
cleanALL:
	rm -f data/sim-hoc-data.csv data/sim-hoc-data.rds