import torch
import timm
import sys
from pprint import pprint

def onnx_224(batch,name):
    model = timm.create_model(name,pretrained=True)
    dummy = torch.randn(batch,3,224,224)
    model.eval()
    try:
        torch.onnx.export(model,dummy,name+'i'+str(batch)+'.onnx')
        print(name,'exported')
    except Exception:
        print(name,'not exported')

model_names = timm.list_models(pretrained=True)
for model_name in model_names:
    print(model_name)

onnx_224(1,"cspresnext50")

sys.exit()

regnets = ["regnetx_002","regnetx_004","regnetx_006","regnetx_008","regnetx_016","regnetx_032","regnetx_040","regnetx_064","regnetx_120","regnetx_160","regnetx_320","regnety_002","regnety_004","regnety_006","regnety_008","regnety_016","regnety_032","regnety_040","regnety_064","regnety_120","regnety_160","regnety_320"]
for regnet in regnets:
    onnx_224(1,regnet)

# Try dumping every model
for model_name in model_names:
    onnx_224(model)
