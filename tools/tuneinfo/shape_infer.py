# Shape inference script
#
# Reads an onnx file and creates an updated file with shapes inferred
#
import onnx
import argparse
import sys
from onnx import helper,shape_inference

def main():
    if len(sys.argv) < 3:
        print("Usage: python shape_infer.py input.onnx output.onnx")
        sys.exit(1)
    model = onnx.load(sys.argv[1])
    inferred_model = shape_inference.infer_shapes(model)
    onnx.save(inferred_model,sys.argv[2])

if __name__ == "__main__":
    main()
    
