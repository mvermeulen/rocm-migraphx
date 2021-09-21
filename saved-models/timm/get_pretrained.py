import torch
import timm
from pprint import pprint

model_names = timm.list_models(pretrained=True)

for model_name in model_names:
    batch=1
    model = timm.create_model(model_name,pretrained=True)
    # try only 224x224 images for now
    dummy=torch.randn(batch,3,224,224)    
    model.eval()

    try:
        torch.onnx.export(model,dummy,model_name+'i'+str(batch)+'.onnx')
        print(model_name,'exported')
    except Exception:
        print(model_name,'not exported')
