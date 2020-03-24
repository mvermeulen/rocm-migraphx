#!/bin/bash
#
# Generate TST (tab separated token) files with following format:
#
# <label> \t <sentence1> \t <sentence2>
#
# where <sentence1> and <sentence2> are both comma separated lists of tokens
env GLUE_TST=1 GLUE_TASK=CoLA ./glue_dump.sh > CoLA.tst 2> CoLA.err
env GLUE_TST=1 GLUE_TASK=SST ./glue_dump.sh > SST.tst   2> SST.err
env GLUE_TST=1 GLUE_TASK=MRPC ./glue_dump.sh > MRPC.tst 2> MRPC.err
env GLUE_TST=1 GLUE_TASK=QQP ./glue_dump.sh > QQP.tst   2> QQP.err
env GLUE_TST=1 GLUE_TASK=STS ./glue_dump.sh > STS.tst   2> STS.err
env GLUE_TST=1 GLUE_TASK=MNLI ./glue_dump.sh > MNLI.tst 2> MNLI.err
env GLUE_TST=1 GLUE_TASK=QNLI ./glue_dump.sh > QNLI.tst 2> QNLI.err
env GLUE_TST=1 GLUE_TASK=RTE ./glue_dump.sh > RTE.tst   2> RTE.err
env GLUE_TST=1 GLUE_TASK=WNLI ./glue_dump.sh > WNLI.tst 2> WNLI.err
