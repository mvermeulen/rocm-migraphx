# script to download and save pytorch torchvision models to ONNX files
import torch
import torchvision.models as models

def resnet18():
    resnet18 = models.resnet18(pretrained=True)
    resnet18.eval()
    for batch in 1,2,4,8,16,32,64,128:
        filename='resnet18i'+str(batch)+'.onnx'
        print(filename)
        torch.onnx.export(resnet18,torch.randn(batch,3,224,224),filename)

def resnet34():
    resnet34 = models.resnet34(pretrained=True)
    resnet34.eval()
    for batch in 1,2,4,8,16,32,64:
        filename='resnet34i'+str(batch)+'.onnx'
        print(filename)
        torch.onnx.export(resnet34,torch.randn(batch,3,224,224),filename)        

def resnet50():
    resnet50 = models.resnet50(pretrained=True)
    resnet50.eval()
    for batch in 1,2,4,8,16,32,64:
        filename='resnet50i'+str(batch)+'.onnx'
        print(filename)
        torch.onnx.export(resnet50,torch.randn(batch,3,224,224),filename)

def resnet101():
    resnet101 = models.resnet101(pretrained=True)
    resnet101.eval()
    for batch in 1,2,4,8,16,32:
        filename='resnet101i'+str(batch)+'.onnx'
        print(filename)
        torch.onnx.export(resnet101,torch.randn(batch,3,224,224),filename)

def resnet152():
    resnet152 = models.resnet152(pretrained=True)
    resnet152.eval()
    for batch in 1,2,4,8,16,32:
        filename='resnet152i'+str(batch)+'.onnx'
        print(filename)
        torch.onnx.export(resnet152,torch.randn(batch,3,224,224),filename)

def resnet():
#    resnet18()
#    resnet34()
    resnet50()
#    resnet101()
#    resnet152()

def inception():
    inception = models.inception_v3(pretrained=True)
    inception.eval()
    for batch in 1,2,4,8,16,32:
        filename='inceptioni'+str(batch)+'.onnx'
        print(filename)
        torch.onnx.export(inception,torch.randn(batch,3,299,299),filename)

def squeezenet10():
    squeezenet = models.squeezenet1_0()
    squeezenet.eval()
    for batch in 1,2,4,8,16,32,64,128,256:
        filename='squeezenet10i'+str(batch)+'.onnx'
        print(filename)
        torch.onnx.export(squeezenet,torch.randn(batch,3,224,224),filename)

def squeezenet11():
    squeezenet = models.squeezenet1_1()
    squeezenet.eval()
    for batch in 1,2,4,8,16,32,64,128,256:
        filename='squeezenet11i'+str(batch)+'.onnx'
        print(filename)
        torch.onnx.export(squeezenet,torch.randn(batch,3,224,224),filename)        

def squeezenet():
    squeezenet10()
    squeezenet11()

def alexnet():
    alexnet = models.alexnet(pretrained=True)
    alexnet.eval()
    for batch in 1,2,4,8,16,32,64,128,256:
        filename='alexneti'+str(batch)+'.onnx'
        print(filename)
        torch.onnx.export(alexnet,torch.randn(batch,3,224,224),filename)

def densenet121():
    densenet = models.densenet121(pretrained=True)
    densenet.eval()
    for batch in 1,2,4,8,16,32:
        filename='densenet121i'+str(batch)+'.onnx'
        print(filename)
        torch.onnx.export(densenet,torch.randn(batch,3,224,224),filename)    

def densenet169():
    densenet = models.densenet169(pretrained=True)
    densenet.eval()
    for batch in 1,2,4,8,16,32:
        filename='densenet169i'+str(batch)+'.onnx'
        print(filename)
        torch.onnx.export(densenet,torch.randn(batch,3,224,224),filename)

def densenet161():
    densenet = models.densenet161(pretrained=True)
    densenet.eval()
    for batch in 1,2,4,8,16:
        filename='densenet161i'+str(batch)+'.onnx'
        print(filename)
        torch.onnx.export(densenet,torch.randn(batch,3,224,224),filename)

def densenet201():
    densenet = models.densenet201(pretrained=True)
    densenet.eval()
    for batch in 1,2,4,8,16:
        filename='densenet201i'+str(batch)+'.onnx'
        print(filename)
        torch.onnx.export(densenet,torch.randn(batch,3,224,224),filename)        
        
def densenet():
    densenet121()
    densenet169()
    densenet161()    
    densenet201()

def vgg11():
    vgg = models.vgg11(pretrained=True)
    vgg.eval()
    for batch in 1,2,4,8,16,32,64:
        filename='vgg11i'+str(batch)+'.onnx'
        print(filename)
        torch.onnx.export(vgg,torch.randn(batch,3,224,224),filename)

def vgg13():
    vgg = models.vgg13(pretrained=True)
    vgg.eval()
    for batch in 1,2,4,8,16,32:
        filename='vgg13i'+str(batch)+'.onnx'
        print(filename)
        torch.onnx.export(vgg,torch.randn(batch,3,224,224),filename)

def vgg16():
    vgg = models.vgg16(pretrained=True)
    vgg.eval()
    for batch in 1,2,4,8,16,32:
        filename='vgg16i'+str(batch)+'.onnx'
        print(filename)
        torch.onnx.export(vgg,torch.randn(batch,3,224,224),filename)

def vgg19():
    vgg = models.vgg19(pretrained=True)
    vgg.eval()
    for batch in 1,2,4,8,16:
        filename='vgg19i'+str(batch)+'.onnx'
        print(filename)
        torch.onnx.export(vgg,torch.randn(batch,3,224,224),filename)

def vgg():
    vgg11()
    vgg13()
    vgg16()
    vgg19()

resnet()
inception()
# squeezenet gives me errors when trying to export
squeezenet()
alexnet()
densenet()
vgg()
