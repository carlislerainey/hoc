
# phonies
all: sim dag
sim: sim/gen/looic.png

# draw makefile dag, see https://gist.github.com/carlislerainey/9a1e49cb195076165a4f07a683ce05a7
dag: makefile-dag.png
makefile-dag.png: Makefile
	make -Bnd | make2graph | dot -Tpng -Gdpi=300 -o makefile-dag.png

# ---------
# fake data
# ---------
# simulate fake data
sim/gen/data.rds: sim/sim-data.R
	Rscript $<
# fit normal regression 
sim/gen/stanfit-norm.rds sim/gen/loo-norm.rds ppd/gen/ppd-norm.png: sim/fit-norm.R stan/norm.stan sim/gen/data.rds
	Rscript $<
# fit heteroskedastic student's t regression 
sim/gen/stanfit-het-t.rds sim/gen/loo-het-t.rds sim/gen/ppd-het-t.png: sim/fit-het-t.R stan/het-t.stan sim/gen/data.rds
	Rscript $<	
# fit hoc regression 
sim/gen/stanfit-hoc.rds sim/gen/loo-hoc.rds sim/gen/ppd-hoc.png: sim/fit-hoc.R stan/hoc.stan sim/gen/data.rds
	Rscript $<	
# compare fits
sim/gen/looic.png: sim/compare-loo.R sim/gen/loo-norm.rds sim/gen/loo-het-t.rds sim/gen/loo-hoc.rds
	Rscript $<		

# ----------------
# cleaning phonies
# ----------------
cleansim:
	rm -f sim/gen/*
	rm -f stan/*.rds
cleanALL: cleansim
	
