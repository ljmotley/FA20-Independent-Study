FUNCTIONS = $(shell cat ../../shell_functions.sh)
# STATA = @$(FUNCTIONS); stata_with_flag
R = @$(FUNCTIONS); R_pc_and_slurm

STATA = stataic -e

#If 'make -n' option is invoked
ifneq (,$(findstring n,$(MAKEFLAGS)))
STATA := stataic
R := R
endif
