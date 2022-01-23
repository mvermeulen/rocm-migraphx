Resnet50 tuning comparisons
---------------------------

Docker image used: rocm-tuning:18.04-5.0-rc2

1. Tuning using MIOpenDriver (created from run_tune.sh)

---

1. Tuning using MIGraphX w/o fusions (created from run_tune3.sh)
   miopen=resnet50i1.migx_nofusion/miopen

   MIGraphX default (fusion): 11.5078
   MIGraphX no fusion:	       2.95465

2. Tuning using MIGraphX w/ fusions (created from run_tune2.sh)
   miopen=resnet50i1.migx:

   MIGraphX default (fusion): 16.68	!! seems off...
   MIGraphX no fusion:	      16.68

3. Tuning using MIOpenDriver (created from run_tune.sh)
   resnet50.fusion.driver.2/miopen

   MIGraphX default (fusion):	11.449
   MIGraphX no fusion:		3.01648
   
   resnet50.nofusion.driver.2/miopen = core dumps?

   MIGraphX default (fusion):
   MIGraphX no fusion:
