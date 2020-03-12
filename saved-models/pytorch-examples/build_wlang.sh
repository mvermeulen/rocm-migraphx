#!/bin/bash
git clone https://github.com/pytorch/examples
cd examples/word_language_model
python3 main.py --epochs 1 --model=GRU --onnx-export=../../wlang_gru.onnx
python3 main.py --epochs 1 --model=LSTM --onnx-export=../../wlang_lstm.onnx
python3 main.py --epochs 1 --model=RNN_TANH --onnx-export=../../wlang_rnn_tanh.onnx
python3 main.py --epochs 1 --model=RNN_RELU --onnx-export=../../wlang_rnn_relu.onnx
