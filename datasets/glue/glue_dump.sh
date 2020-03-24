#!/bin/bash
# Dump output lines from GLUE .tsv files
# By default, dumps into ASCII format, but when GLUE_TST variable is set dumps to the following format:
#
# <label>\t<tokens1>\t<tokens2>
#
# where <tokens1> and <tokens2> are comma separated.
GLUE_DATA=${GLUE_DATA:="./glue_data"}
GLUE_TASK=${GLUE_TASK:="CoLA"}
GLUE_TST=${GLUE_TST:=0}

case ${GLUE_TASK} in
# Single Sentence Tasks
    
    # Corpus of Linguistic Acceptability
    # Single sentences annotated whether they are gramatical sentences
    CoLA)
	validation_file=${GLUE_DATA}/CoLA/dev.tsv
	awk_fields='{ print $2 "|" $4 }'
	;;
    # Stanford Sentiment Treebank
    # Single sentences from movie reviews. Annotated whether they are positive or negative.
    SST)
	validation_file=${GLUE_DATA}/SST-2/dev.tsv
	awk_fields='{ print $2 "|" $1 }'
	;;

# Similarity and paraphrase tasks    
    # Microsoft Research Paraphrase Corpus
    # Pairs of sentences from online news sources, are they semantically equivalent?
    # Unbalanced (68% positive)
    MRPC)
	validation_file=${GLUE_DATA}/MRPC/dev.tsv
	awk_fields='{ print $1 "|" $4 "|" $5 }'
	;;

    # Quora Question Pairs
    # Are the questions semantically equivalent?
    # Unbalanced (63% negative)
    QQP)
	validation_file=${GLUE_DATA}/QQP/dev.tsv
	awk_fields='{ print $6 "|" $4 "|" $5 }'	
	;;

    # Semantic Textual Similarity
    # Sentence pairs drawn from news headlines, are they similar? (0 to 5)
    STS)
	validation_file=${GLUE_DATA}/STS-B/dev.tsv
	awk_fields='{ print $10 "|" $8 "|" $9 }'
	;;

# Inference tasks    
    # Multi-Genre Natural Language Inference Corpus
    # Given a premise + hypothesis; does the premise entail the hypothesis, contradict the hypothesis or is it neutral
    # Looks at both matched (in domain) and mis-matched (cross-domain)
    MNLI)
	validation_file=${GLUE_DATA}/MNLI/dev_matched.tsv
	awk_fields='{ print $16 "|" $9 "|" $10 }'
	;;

    # Stanford Question Answering Dataset
    # Does the second sentence answer the question?
    QNLI)
	validation_file=${GLUE_DATA}/QNLI/dev.tsv
	awk_fields='{ print $4 "|" $2 "|" $3 }'
	;;

    # Recognizing Textual Entailment
    # Does the second sentence agree with the first
    RTE)
	validation_file=${GLUE_DATA}/RTE/dev.tsv
	awk_fields='{ print $4 "|" $2 "|" $3 }'	
	;;

    # Winograd Schema Challenge
    # Does the second sentence have the proper pronoun replacement
    WNLI)
	validation_file=${GLUE_DATA}/WNLI/dev.tsv
	awk_fields='{ print $4 "|" $2 "|" $3 }'		
	;;    

    
    *)
	echo "Unknown GLUE_TASK: ${GLUE_TASK}"
	exit 1
esac

IFS='|'
cat $validation_file | awk -F '\t' "$awk_fields" | while read label sentence1 sentence2
do
    if [ "${GLUE_TST}" == "0" ]; then
	echo "label=$label"
	echo "   sentence1=$sentence1"
	echo "   sentence2=$sentence2"
    else
	echo "$label	"`echo $sentence1|./tokenize.sh`"	"`echo $sentence2|./tokenize.sh`
    fi
done
