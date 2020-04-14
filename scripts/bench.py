#
# bench.py - benchmark script for models
#
import argparse
import numpy as np
import cv2 as cv
import time

parser = argparse.ArgumentParser()
parser.add_argument("--framework",default='migraphx',choices=('migraphx','tensorflow'))
parser.add_argument("--model",choices=('resnet50v1','resnet50v2','inceptionv3','vgg16','mobilenet'))
parser.add_argument("--save_file",type=str)
parser.add_argument("--image_file",type=str)
parser.add_argument("--resize_val",type=int,default=224)
parser.add_argument("--repeat",type=int,default=1000)
parser.add_argument("--fp16",action='store_true')
parser.add_argument("--batch",default=0)
args=parser.parse_args()

framework=args.framework
save_file=args.save_file
image_file=args.image_file
resize_val=args.resize_val
model=args.model
repeat=args.repeat
fp16=args.fp16
batch=args.batch

def tf_load_graph(save_file):
    # load the graph
    with tf.io.gfile.GFile(save_file,'rb') as f:
        graph_def = tf.compat.v1.GraphDef()
        graph_def.ParseFromString(f.read())
    with tf.Graph().as_default() as graph:
        tf.import_graph_def(graph_def)
    return graph

def load_image(image_file,batch=1):
    img = cv.imread(image_file)
    img = cv.resize(img,dsize=(resize_val,resize_val))
    if framework == 'migraphx':
        img = img.transpose(2,0,1)
    
    np_img = np.asarray(img)
    np_img_nchw = np.ascontiguousarray(
        np.expand_dims(np_img.astype('float32')/256.0,axis=0))
    print('shape=',np.shape(np_img_nchw))
    batch_np_img_nchw = np.repeat(np_img_nchw,batch,axis=0)
    print('batch shape=',np.shape(batch_np_img_nchw))    
    return batch_np_img_nchw

if batch == 0:
    if model == 'resnet50v1':
        batch = 64
    elif model == 'resnet50v2':
        batch = 64
    elif model == 'inceptionv3':
        batch = 32
    elif model == 'vgg16':
        batch = 16
    elif model == 'mobilenet':
        batch = 64

if framework == 'tensorflow':
    import tensorflow as tf
    graph = tf_load_graph(save_file)
    if fp16:
        opt = tf.keras.optimizers.SGD()
        opt = tf.train.experimental.enable_mixed_precision_graph_rewrite(opt)

    # for op in graph.get_operations():
    #    print(op.name)

    # mobilenet for now
    if model == 'resnet50v1':
        x = graph.get_tensor_by_name('import/input:0')
        y = graph.get_tensor_by_name('import/resnet_v1_50/predictions/Reshape_1:0')
    elif model == 'resnet50v2':
        x = graph.get_tensor_by_name('import/input:0')
        y = graph.get_tensor_by_name('import/resnet_v2_50/predictions/Reshape_1:0')
    elif model == 'inceptionv3':        
        x = graph.get_tensor_by_name('import/input:0')
        y = graph.get_tensor_by_name('import/InceptionV3/Predictions/Reshape_1:0')
    elif model == 'vgg16':        
        x = graph.get_tensor_by_name('import/input:0')
        y = graph.get_tensor_by_name('import/vgg_16/fc8/squeezed:0')
    elif model == 'mobilenet':        
        x = graph.get_tensor_by_name('import/input:0')
        y = graph.get_tensor_by_name('import/MobilenetV1/Predictions/Reshape_1:0')        
        

    image = load_image(image_file,batch)
    
    with tf.compat.v1.Session(graph=graph) as sess:
        # dry run just as long as normal
        for i in range(repeat):
            y_out = sess.run(y,feed_dict={x:image})        
        start_time = time.time()
        for i in range(repeat):
            y_out = sess.run(y,feed_dict={x:image})
        finish_time = time.time()
        result = np.array(y_out)
        idx = np.argmax(result[0])
        print('Tensorflow: ')
        print('IDX  = ',idx)
        print('Time = ', '{:8.3f}'.format(finish_time - start_time))
elif framework == 'migraphx':
    import migraphx
    graph = migraphx.parse_tf(save_file)
    if fp16:
        migraphx.quantize_fp16(graph)
    graph.compile(migraphx.get_target("gpu"))
    # allocate space with random params
    params = {}
    #for key,value in graph.get_parameter_shapes().items():
    #    params[key] = migraphx.allocate_gpu(value)

    image = load_image(image_file,batch)
    for i in range(repeat):    
        params['input'] = migraphx.argument(image)
#        result = np.array(graph.run(params),copy=False)
        result = graph.run(params)
    start_time = time.time()
    for i in range(repeat):    
        params['input'] = migraphx.argument(image)
#        result = np.array(graph.run(params),copy=False)
        result = graph.run(params)
    finish_time = time.time()
    idx = np.argmax(result[0])    
    print('MIGraphX: ')    
    print('IDX  = ',idx)
    print('Time = ', '{:8.3f}'.format(finish_time - start_time))
