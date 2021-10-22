#
# Keras example from: https://www.tensorflow.org/tutorials
#
# Updated to:
# - remove the Dropout layer
# - save frozen *.pb file for use in inference
#
# This example will first train MNIST using an installed tensorflow before
# writing the saved configuration.  I ran this using TF 1.15 docker and then
# saved away the *.pb file.

import tensorflow as tf
mnist = tf.keras.datasets.mnist

(x_train, y_train),(x_test, y_test) = mnist.load_data()
x_train, x_test = x_train / 255.0, x_test / 255.0

model = tf.keras.models.Sequential([
  tf.keras.layers.Flatten(input_shape=(28, 28)),
  tf.keras.layers.Dense(512, activation=tf.nn.relu),
#  tf.keras.layers.Dropout(0.2),
  tf.keras.layers.Dense(10, activation=tf.nn.softmax)
])
model.compile(optimizer='adam',
              loss='sparse_categorical_crossentropy',
              metrics=['accuracy'])

model.fit(x_train, y_train, epochs=5)
model.evaluate(x_test, y_test)

sess = tf.Session()
sess.run(tf.global_variables_initializer())
#tf.train.write_graph(sess.graph_def,".","mnist.pbtxt")
#tf.train.write_graph(sess.graph_def,".","mnist.pb",as_text=False)

graph_def = tf.get_default_graph().as_graph_def()
output_graph = tf.graph_util.convert_variables_to_constants(sess,graph_def,['dense_1/Softmax'])
with tf.gfile.GFile('frozen_mnist.pb','wb') as f:
    f.write(output_graph.SerializeToString())
