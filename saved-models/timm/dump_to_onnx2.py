import torch
import argparse
import timm
import sys
from pprint import pprint

parser = argparse.ArgumentParser()
parser.add_argument("--batch",type=int,default=1)
parser.add_argument("--size",type=int,default=-1)
parser.add_argument("--name",type=str)
parser.add_argument("--list",action='store_true')
parser.add_argument("--input",action='store_true')
args=parser.parse_args()
name=args.name

if args.list:
    model_names = timm.list_models(pretrained=True)
    for model_name in model_names:
        print(model_name)
elif args.input:
    model = timm.create_model(name,pretrained=True)
    print(model.default_cfg['input_size'])
elif args.size==-1:
    model = timm.create_model(name,pretrained=True)
    dummy = torch.randn(args.batch,*model.default_cfg['input_size'])
    model.eval()
    try:
        torch.onnx.export(model,dummy,name+'i'+str(args.batch)+'.onnx')
        print(name,'exported')
    except Exception:
        print(name,'not exported')
else:
    model = timm.create_model(name,pretrained=True)
    dummy = torch.randn(args.batch,3,args.size,args.size)
    model.eval()
    try:
        torch.onnx.export(model,dummy,name+'i'+str(args.batch)+'_'+str(args.size)+'.onnx')
        print(name,'exported')
    except Exception:
        print(name,'not exported')        


