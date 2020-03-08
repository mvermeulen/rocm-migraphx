# script to download models and save them as ONNX files
#
# NOTE: The batch > X limits set based on what worked on my machine. In some cases,
#       these also depend on available memory left by python, i.e. a model might fail
#       to export if done after others that consume memory.
import torch
import pretrainedmodels
import sys
import os.path
# set the directory where torch models are cached, e.g. outside the docker container
os.environ['TORCH_MODEL_ZOO'] = '/home/mev/.torch'
batch_size = 1
regenerate = False   # re-create files even if they exist

def fbresnet152(name,fname,batch):
    if batch > 32:
        return 1
    print(fname)
    model = pretrainedmodels.__dict__[name](num_classes=1000,pretrained='imagenet')
    model.eval()
    torch.onnx.export(model,torch.randn(batch,model.input_size[0],model.input_size[1],model.input_size[2]),filename)
    return 0

def bninception(name,fname,batch):
# ONNX export fails operator aten::max_pool2d
    return 2
    print(fname)
    model = pretrainedmodels.__dict__[name](num_classes=1000,pretrained='imagenet')
    model.eval()
    torch.onnx.export(model,torch.randn(batch,model.input_size[0],model.input_size[1],model.input_size[2]),filename)
    return 0

def resnext101_32x4d(name,fname,batch):
    if batch > 16:
        return 1
    print(fname)
    model = pretrainedmodels.__dict__[name](num_classes=1000,pretrained='imagenet')
    model.eval()
    torch.onnx.export(model,torch.randn(batch,model.input_size[0],model.input_size[1],model.input_size[2]),filename)
    return 0

def resnext101_64x4d(name,fname,batch):
    if batch > 16:
        return 1
    print(fname)
    model = pretrainedmodels.__dict__[name](num_classes=1000,pretrained='imagenet')
    model.eval()
    torch.onnx.export(model,torch.randn(batch,model.input_size[0],model.input_size[1],model.input_size[2]),filename)
    return 0    

def inceptionv4(name,fname,batch):
    if batch > 16:
        return 1
    print(fname)
    model = pretrainedmodels.__dict__[name](num_classes=1000,pretrained='imagenet')
    model.eval()
    torch.onnx.export(model,torch.randn(batch,model.input_size[0],model.input_size[1],model.input_size[2]),filename)
    return 0    
    
def inceptionresnetv2(name,fname,batch):
    if batch > 16:
        return 1
    print(fname)
    model = pretrainedmodels.__dict__[name](num_classes=1000,pretrained='imagenet')
    model.eval()
    torch.onnx.export(model,torch.randn(batch,model.input_size[0],model.input_size[1],model.input_size[2]),filename)
    return 0    
    
def alexnet(name,fname,batch):
    if batch > 256:
        return 1    
    print(fname)
    model = pretrainedmodels.__dict__[name](num_classes=1000,pretrained='imagenet')
    model.eval()
    torch.onnx.export(model,torch.randn(batch,model.input_size[0],model.input_size[1],model.input_size[2]),filename)
    return 0    
    
def densenet121(name,fname,batch):
    if batch > 32:
        return 1
    print(fname)
    model = pretrainedmodels.__dict__[name](num_classes=1000,pretrained='imagenet')
    model.eval()
    torch.onnx.export(model,torch.randn(batch,model.input_size[0],model.input_size[1],model.input_size[2]),filename)
    return 0    
    
def densenet169(name,fname,batch):
    if batch > 32:
        return 1
    print(fname)
    model = pretrainedmodels.__dict__[name](num_classes=1000,pretrained='imagenet')
    model.eval()
    torch.onnx.export(model,torch.randn(batch,model.input_size[0],model.input_size[1],model.input_size[2]),filename)
    return 0    
    
def densenet201(name,fname,batch):
    if batch > 16:
        return 1
    print(fname)
    model = pretrainedmodels.__dict__[name](num_classes=1000,pretrained='imagenet')
    model.eval()
    torch.onnx.export(model,torch.randn(batch,model.input_size[0],model.input_size[1],model.input_size[2]),filename)
    return 0    
    
def densenet161(name,fname,batch):
    if batch > 16:
        return 1
    print(fname)
    model = pretrainedmodels.__dict__[name](num_classes=1000,pretrained='imagenet')
    model.eval()
    torch.onnx.export(model,torch.randn(batch,model.input_size[0],model.input_size[1],model.input_size[2]),filename)
    return 0    

def resnet18(name,fname,batch):
    if batch > 128:
        return 1    
    print(fname)
    model = pretrainedmodels.__dict__[name](num_classes=1000,pretrained='imagenet')
    model.eval()
    torch.onnx.export(model,torch.randn(batch,model.input_size[0],model.input_size[1],model.input_size[2]),filename)
    return 0    
    
def resnet34(name,fname,batch):
    if batch > 64:
        return 1    
    print(fname)
    model = pretrainedmodels.__dict__[name](num_classes=1000,pretrained='imagenet')
    model.eval()
    torch.onnx.export(model,torch.randn(batch,model.input_size[0],model.input_size[1],model.input_size[2]),filename)
    return 0    
    
def resnet50(name,fname,batch):
    if batch > 64:
        return 1    
    print(fname)
    model = pretrainedmodels.__dict__[name](num_classes=1000,pretrained='imagenet')
    model.eval()
    torch.onnx.export(model,torch.randn(batch,model.input_size[0],model.input_size[1],model.input_size[2]),filename)
    return 0    
    
def resnet101(name,fname,batch):
    if batch > 32:
        return 1
    print(fname)
    model = pretrainedmodels.__dict__[name](num_classes=1000,pretrained='imagenet')
    model.eval()
    torch.onnx.export(model,torch.randn(batch,model.input_size[0],model.input_size[1],model.input_size[2]),filename)
    return 0    
    
def resnet152(name,fname,batch):
    if batch > 32:
        return 1
    print(fname)
    model = pretrainedmodels.__dict__[name](num_classes=1000,pretrained='imagenet')
    model.eval()
    torch.onnx.export(model,torch.randn(batch,model.input_size[0],model.input_size[1],model.input_size[2]),filename)
    return 0    
    
def inceptionv3(name,fname,batch):
    if batch > 32:
        return 1
    print(fname)
    model = pretrainedmodels.__dict__[name](num_classes=1000,pretrained='imagenet')
    model.eval()
    torch.onnx.export(model,torch.randn(batch,model.input_size[0],model.input_size[1],model.input_size[2]),filename)
    return 0    
    
def squeezenet1_0(name,fname,batch):
#   ONNX export failed: aten::max_pool2d
    return 2
    print(fname)
    model = pretrainedmodels.__dict__[name](num_classes=1000,pretrained='imagenet')
    model.eval()
    torch.onnx.export(model,torch.randn(batch,model.input_size[0],model.input_size[1],model.input_size[2]),filename)
    return 0    
    
def squeezenet1_1(name,fname,batch):
#   ONNX export failed: aten::max_pool2d
    return 2
    print(fname)
    model = pretrainedmodels.__dict__[name](num_classes=1000,pretrained='imagenet')
    model.eval()
    torch.onnx.export(model,torch.randn(batch,model.input_size[0],model.input_size[1],model.input_size[2]),filename)
    return 0    
    
def vgg11(name,fname,batch):
    if batch > 64:
        return 1    
    print(fname)
    model = pretrainedmodels.__dict__[name](num_classes=1000,pretrained='imagenet')
    model.eval()
    torch.onnx.export(model,torch.randn(batch,model.input_size[0],model.input_size[1],model.input_size[2]),filename)
    return 0    
    
def vgg11_bn(name,fname,batch):
    if batch > 64:
        return 1    
    print(fname)
    model = pretrainedmodels.__dict__[name](num_classes=1000,pretrained='imagenet')
    model.eval()
    torch.onnx.export(model,torch.randn(batch,model.input_size[0],model.input_size[1],model.input_size[2]),filename)
    return 0    
    
def vgg13(name,fname,batch):
    if batch > 32:
        return 1
    print(fname)
    model = pretrainedmodels.__dict__[name](num_classes=1000,pretrained='imagenet')
    model.eval()
    torch.onnx.export(model,torch.randn(batch,model.input_size[0],model.input_size[1],model.input_size[2]),filename)
    return 0    
    
def vgg13_bn(name,fname,batch):
    if batch > 32:
        return 1    
    print(fname)
    model = pretrainedmodels.__dict__[name](num_classes=1000,pretrained='imagenet')
    model.eval()
    torch.onnx.export(model,torch.randn(batch,model.input_size[0],model.input_size[1],model.input_size[2]),filename)
    return 0    
    
def vgg16(name,fname,batch):
    if batch > 16:
        return 1
    print(fname)
    model = pretrainedmodels.__dict__[name](num_classes=1000,pretrained='imagenet')
    model.eval()
    torch.onnx.export(model,torch.randn(batch,model.input_size[0],model.input_size[1],model.input_size[2]),filename)
    return 0    
    
def vgg16_bn(name,fname,batch):
    if batch > 16:
        return 1 
    print(fname)
    model = pretrainedmodels.__dict__[name](num_classes=1000,pretrained='imagenet')
    model.eval()
    torch.onnx.export(model,torch.randn(batch,model.input_size[0],model.input_size[1],model.input_size[2]),filename)
    return 0    
    
def vgg19_bn(name,fname,batch):
    if batch > 16:
        return 1 
    print(fname)
    model = pretrainedmodels.__dict__[name](num_classes=1000,pretrained='imagenet')
    model.eval()
    torch.onnx.export(model,torch.randn(batch,model.input_size[0],model.input_size[1],model.input_size[2]),filename)
    return 0    
    
def vgg19(name,fname,batch):
    if batch > 16:
        return 1 
    print(fname)
    model = pretrainedmodels.__dict__[name](num_classes=1000,pretrained='imagenet')
    model.eval()
    torch.onnx.export(model,torch.randn(batch,model.input_size[0],model.input_size[1],model.input_size[2]),filename)
    return 0    
    
def nasnetamobile(name,fname,batch):
    if batch > 32:
        return 1    
    print(fname)
    model = pretrainedmodels.__dict__[name](num_classes=1000,pretrained='imagenet')
    model.eval()
    torch.onnx.export(model,torch.randn(batch,model.input_size[0],model.input_size[1],model.input_size[2]),filename)
    return 0    
    
def nasnetalarge(name,fname,batch):
    if batch > 2:
        return 1
    print(fname)
    model = pretrainedmodels.__dict__[name](num_classes=1000,pretrained='imagenet')
    model.eval()
    torch.onnx.export(model,torch.randn(batch,model.input_size[0],model.input_size[1],model.input_size[2]),filename)
    return 0    
    
def dpn68(name,fname,batch):
    if batch > 32:
        return 1    
    print(fname)
    model = pretrainedmodels.__dict__[name](num_classes=1000,pretrained='imagenet')
    model.eval()
    torch.onnx.export(model,torch.randn(batch,model.input_size[0],model.input_size[1],model.input_size[2]),filename)
    return 0    
    
def dpn68b(name,fname,batch):
    if batch > 32:
        return 1    
    print(fname)
    model = pretrainedmodels.__dict__[name](num_classes=1000,pretrained='imagenet+5k')    
    model.eval()
    torch.onnx.export(model,torch.randn(batch,model.input_size[0],model.input_size[1],model.input_size[2]),filename)
    return 0    
    
def dpn92(name,fname,batch):
    if batch > 32:
        return 1    
    print(fname)
    model = pretrainedmodels.__dict__[name](num_classes=1000,pretrained='imagenet+5k')
    model.eval()
    torch.onnx.export(model,torch.randn(batch,model.input_size[0],model.input_size[1],model.input_size[2]),filename)
    return 0    
    
def dpn98(name,fname,batch):
    if batch > 16:
        return 1 
    print(fname)
    model = pretrainedmodels.__dict__[name](num_classes=1000,pretrained='imagenet')
    model.eval()
    torch.onnx.export(model,torch.randn(batch,model.input_size[0],model.input_size[1],model.input_size[2]),filename)
    return 0    
    
def dpn131(name,fname,batch):
    if batch > 16:
        return 1 
    print(fname)
    model = pretrainedmodels.__dict__[name](num_classes=1000,pretrained='imagenet')
    model.eval()
    torch.onnx.export(model,torch.randn(batch,model.input_size[0],model.input_size[1],model.input_size[2]),filename)
    return 0    
    
def dpn107(name,fname,batch):
    if batch > 16:
        return 1    
    print(fname)
    model = pretrainedmodels.__dict__[name](num_classes=1000,pretrained='imagenet+5k')
    model.eval()
    torch.onnx.export(model,torch.randn(batch,model.input_size[0],model.input_size[1],model.input_size[2]),filename)
    return 0    
    
def xception(name,fname,batch):
# ONNX export fails aten::adaptive_avg_pool2d
    return 2
    print(fname)
    model = pretrainedmodels.__dict__[name](num_classes=1000,pretrained='imagenet')
    model.eval()
    torch.onnx.export(model,torch.randn(batch,model.input_size[0],model.input_size[1],model.input_size[2]),filename)
    return 0
    
def senet154(name,fname,batch):
# ONNX export fails aten::max_pool2d
    return 2
    print(fname)
    model = pretrainedmodels.__dict__[name](num_classes=1000,pretrained='imagenet')
    model.eval()
    torch.onnx.export(model,torch.randn(batch,model.input_size[0],model.input_size[1],model.input_size[2]),filename)
    return 0    
    
def se_resnet50(name,fname,batch):
# ONNX export fails aten::max_pool2d
    return 2    
    print(fname)
    model = pretrainedmodels.__dict__[name](num_classes=1000,pretrained='imagenet')
    model.eval()
    torch.onnx.export(model,torch.randn(batch,model.input_size[0],model.input_size[1],model.input_size[2]),filename)
    return 0    
    
def se_resnet101(name,fname,batch):
# ONNX export fails aten::max_pool2d
    return 2    
    print(fname)
    model = pretrainedmodels.__dict__[name](num_classes=1000,pretrained='imagenet')
    model.eval()
    torch.onnx.export(model,torch.randn(batch,model.input_size[0],model.input_size[1],model.input_size[2]),filename)
    return 0    
    
def se_resnet152(name,fname,batch):
# ONNX export fails aten::max_pool2d
    return 2    
    print(fname)
    model = pretrainedmodels.__dict__[name](num_classes=1000,pretrained='imagenet')
    model.eval()
    torch.onnx.export(model,torch.randn(batch,model.input_size[0],model.input_size[1],model.input_size[2]),filename)
    return 0    
    
def se_resnext50_32x4d(name,fname,batch):
# ONNX export fails aten::max_pool2d
    return 2    
    print(fname)
    model = pretrainedmodels.__dict__[name](num_classes=1000,pretrained='imagenet')
    model.eval()
    torch.onnx.export(model,torch.randn(batch,model.input_size[0],model.input_size[1],model.input_size[2]),filename)
    return 0    
    
def se_resnext101_32x4d(name,fname,batch):
# ONNX export fails aten::max_pool2d
    return 2    
    print(fname)
    model = pretrainedmodels.__dict__[name](num_classes=1000,pretrained='imagenet')
    model.eval()
    torch.onnx.export(model,torch.randn(batch,model.input_size[0],model.input_size[1],model.input_size[2]),filename)
    return 0    
    
def cafferesnet101(name,fname,batch):
# ONNX export fails aten::max_pool2d
    return 2
    print(fname)
    model = pretrainedmodels.__dict__[name](num_classes=1000,pretrained='imagenet')
    model.eval()
    torch.onnx.export(model,torch.randn(batch,model.input_size[0],model.input_size[1],model.input_size[2]),filename)
    return 0    
    
def pnasnet5large(name,fname,batch):
    if batch > 2:
        return 1
    print(fname)
    model = pretrainedmodels.__dict__[name](num_classes=1000,pretrained='imagenet')
    model.eval()
    torch.onnx.export(model,torch.randn(batch,model.input_size[0],model.input_size[1],model.input_size[2]),filename)
    return 0    
    
def polynet(name,fname,batch):
# ONNX export fails Auto nesting doesn't know how to process input object of type int
    return 2    
    print(fname)
    model = pretrainedmodels.__dict__[name](num_classes=1000,pretrained='imagenet')
    model.eval()
    torch.onnx.export(model,torch.randn(batch,model.input_size[0],model.input_size[1],model.input_size[2]),filename)
    return 0    

for batch in 1,2,4,8,16,32,64,128,256:
    for model in pretrainedmodels.model_names:
        filename=model+'i'+str(batch)+'.onnx'
        if os.path.exists(filename) and not regenerate:
            continue

        # fairly simple if/tree, may be more elegant way, but does the job
        ret = 3
        if model == 'fbresnet152':
            ret = fbresnet152(model,filename,batch)
        elif model == 'bninception':
            ret = bninception(model,filename,batch)
        elif model == 'resnext101_32x4d':
            ret = resnext101_32x4d(model,filename,batch)
        elif model == 'resnext101_64x4d':
            ret =  resnext101_64x4d(model,filename,batch)
        elif model == 'inceptionv4':
            ret =  inceptionv4(model,filename,batch)
        elif model == 'inceptionresnetv2':
            ret =  inceptionresnetv2(model,filename,batch)
        elif model == 'alexnet':
            ret =  alexnet(model,filename,batch)
        elif model == 'densenet121':
            ret =  densenet121(model,filename,batch)
        elif model == 'densenet169':
            ret =  densenet169(model,filename,batch)
        elif model == 'densenet201':
            ret =  densenet201(model,filename,batch)
        elif model == 'densenet161':
            ret =  densenet161(model,filename,batch)
        elif model == 'resnet18':
            ret =  resnet18(model,filename,batch)
        elif model == 'resnet34':
            ret =  resnet34(model,filename,batch)
        elif model == 'resnet50':
            ret =  resnet50(model,filename,batch)
        elif model == 'resnet101':
            ret =  resnet101(model,filename,batch)
        elif model == 'resnet152':
            ret =  resnet152(model,filename,batch)
        elif model == 'inceptionv3':
            ret =  inceptionv3(model,filename,batch)
        elif model == 'squeezenet1_0':
            ret =  squeezenet1_0(model,filename,batch)
        elif model == 'squeezenet1_1':
            ret =  squeezenet1_1(model,filename,batch)
        elif model == 'vgg11':
            ret =  vgg11(model,filename,batch)
        elif model == 'vgg11_bn':
            ret =  vgg11_bn(model,filename,batch)
        elif model == 'vgg13':
            ret =  vgg13(model,filename,batch)
        elif model == 'vgg13_bn':
            ret =  vgg13_bn(model,filename,batch)
        elif model == 'vgg16':
            ret =  vgg16(model,filename,batch)
        elif model == 'vgg16_bn':
            ret =  vgg16_bn(model,filename,batch)
        elif model == 'vgg19_bn':
            ret =  vgg19_bn(model,filename,batch)
        elif model == 'vgg19':
            ret =  vgg19(model,filename,batch)
        elif model == 'nasnetamobile':
            ret =  nasnetamobile(model,filename,batch)
        elif model == 'nasnetalarge':
            ret =  nasnetalarge(model,filename,batch)
        elif model == 'dpn68':
            ret =  dpn68(model,filename,batch)
        elif model == 'dpn68b':
            ret =  dpn68b(model,filename,batch)
        elif model == 'dpn92':
            ret =  dpn92(model,filename,batch)
        elif model == 'dpn98':
            ret =  dpn98(model,filename,batch)
        elif model == 'dpn131':
            ret =  dpn131(model,filename,batch)
        elif model == 'dpn107':
            ret =  dpn107(model,filename,batch)
        elif model == 'xception':
            ret =  xception(model,filename,batch)
        elif model == 'senet154':
            ret =  senet154(model,filename,batch)
        elif model == 'se_resnet50':
            ret =  se_resnet50(model,filename,batch)
        elif model == 'se_resnet101':
            ret =  se_resnet101(model,filename,batch)
        elif model == 'se_resnet152':
            ret =  se_resnet152(model,filename,batch)
        elif model == 'se_resnext50_32x4d':
            ret =  se_resnext50_32x4d(model,filename,batch)
        elif model == 'se_resnext101_32x4d':
            ret =  se_resnext101_32x4d(model,filename,batch)
        elif model == 'cafferesnet101':
            ret =  cafferesnet101(model,filename,batch)
        elif model == 'pnasnet5large':
            ret =  pnasnet5large(model,filename,batch)
        elif model == 'polynet':
            ret =  polynet(model,filename,batch)

        # deal with return codes
        if ret == 0:
            continue
        elif ret == 1:
            print('Batch size ',batch,' not implemented for ',model)
            continue
        elif ret == 2:
            print('ONNX export fails for ',model)
            continue
        
        print('Model ',model,' not yet implemented for batch size ',batch)
        print(pretrainedmodels.pretrained_settings[model])
