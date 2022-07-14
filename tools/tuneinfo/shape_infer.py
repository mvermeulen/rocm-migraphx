# Example of shape inference
#
import onnx
from onnx import helper,shape_inference


model = onnx.load("resnet50i1.onnx")
inferred_model = shape_inference.infer_shapes(model)
onnx.save(inferred_model,"resnet50i1_inf.onnx")
