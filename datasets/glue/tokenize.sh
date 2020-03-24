#!/usr/bin/python3
#
# convert stdin into comma separated list of tokens
from pytorch_transformers import BertTokenizer
import sys

tokenizer = BertTokenizer.from_pretrained("bert-base-cased",do_lower_case=False)

for line in sys.stdin:
	    tokens = tokenizer.tokenize(line)
	    token_ids=list(map(tokenizer.convert_tokens_to_ids,tokens))
	    str_token_ids=str(token_ids)
	    print(*token_ids,sep=',')
