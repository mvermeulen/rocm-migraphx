import torch
import argparse
import timm
import sys
from pprint import pprint

parser = argparse.ArgumentParser()
parser.add_argument("--batch",type=int,default=1)
parser.add_argument("--size",type=int,default=224)
parser.add_argument("--name",type=str)
parser.add_argument("--list",action='store_true')
parser.add_argument("--input",action='store_true')
args=parser.parse_args()

def dump_onnx_file(name,batch,size):
    model = timm.create_model(name,pretrained=True)
    dummy = torch.randn(batch,3,size,size)
    model.eval()
    try:
        torch.onnx.export(model,dummy,name+'i'+str(batch)+'.onnx')
        print(name,'exported')
    except Exception:
        print(name,'not exported')

if args.list:
    model_names = timm.list_models(pretrained=True)
    for model_name in model_names:
        print(model_name)
elif args.input:
    model = timm.create_model(args.name,pretrained=True)
    print(model.default_cfg['input_size'])
else:
    dump_onnx_file(args.name,args.batch,args.size)

