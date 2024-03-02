
from random import random_float64, seed
from math import exp
from time import now


struct Array:
    var data: Pointer[Float64]
    var size: Int

    fn __init__(inout self, size: Int):
        self.size = size
        self.data = Pointer[Float64].alloc(self.size)

    fn __init__(inout self, size: Int, default_value:Float64):
        self.size = size
        self.data = Pointer[Float64].alloc(self.size)
        for i in range(self.size):
            self.data.store(i,default_value)

    fn __copyinit__(inout self, copy: Array):
        self.size = copy.size
        self.data = Pointer[Float64].alloc(self.size)
        for i in range(self.size):
            self.data.store(i, copy[i])

    fn __getitem__(self,i:Int) -> Float64:
        return self.data.load(i)

    fn __setitem__(self, i: Int, value: Float64):
        self.data.store(i,value)

    fn __del__(owned self):
        self.data.free()

    fn len(self) -> Int:
        return self.size

struct Array2D:
    var data: Pointer[Float64]
    var sizeX: Int
    var sizeY: Int

    fn __init__(inout self, sizeX:Int, sizeY: Int):
        self.sizeX = sizeX
        self.sizeY = sizeY
        self.data = Pointer[Float64].alloc(self.sizeX*sizeY)

    fn __init__(inout self, sizeX: Int, sizeY:Int, default_value:Float64):
        self.sizeX = sizeX
        self.sizeY = sizeY
        self.data = Pointer[Float64].alloc(self.sizeX*sizeY)
        for i in range(self.sizeX*self.sizeY):
            self.data.store(i,default_value)

    fn __copyinit__(inout self, copy:Array2D):
        self.sizeX = copy.sizeX
        self.sizeY = copy.sizeY
        self.data = Pointer[Float64].alloc(self.sizeX*self.sizeY)
        for i in range(self.sizeX*self.sizeY):
            self.data.store(i, copy[i])

    fn __getitem__(self, i:Int, j: Int) -> Float64:
        return self[self.sizeY * i + j]

    fn __getitem__(self, i: Int) -> Float64:
        return self.data.load(i)

    fn __setitem__(self, i:Int,value:Float64):
        self.data.store(i,value)

    fn __setitem__(self, i: Int, j:Int, value:Float64):
        self[self.sizeY*i + j] = value

    fn __del__(owned self):
        self.data.free()

    fn len(self) -> Int:
        return self.sizeX*self.sizeY

    fn rows(self) -> Int:
        return self.sizeX

    fn columns(self) -> Int:
        return self.sizeY

struct NeuralNetwork:
    var weights: Array
    var bias: Array

    fn __init__(inout self):
        self.weights = Array(6)
        self.bias = Array(3)

        for i in range(6):
            if i < 3:
                self.bias[i] =random_float64()

            self.weights[i] = random_float64()

    fn sigmoid_activation_function(self, x: Float64) -> Float64:
        return 1.0/(1+exp(-x))

    fn feed_forward(self, x0: Float64,x1:Float64, only_predict: Bool = True) -> Array:
        let hidden0 : Float64 = x0 *self.weights[0] + x1*self.weights[1] + self.bias[0]
        let hidden1 : Float64 = x0 * self.weights[2] + x1* self.weights[3] +self.bias[1]
        let output0 : Float64 = x0 * self.weights[4] + x1* self.weights[5] + self.bias[2]

        let sigmoid_hidden0: Float64 = self.sigmoid_activation_function(hidden0)
        let sigmoid_hidden1: Float64 = self.sigmoid_activation_function(hidden1)
        let sigmoid_output0: Float64 = self.sigmoid_activation_function(output0)

        if only_predict:
            return Array(1, sigmoid_output0)

        let t = Array(6)
        t[0] = hidden0
        t[1] = sigmoid_hidden0
        t[2] = hidden1
        t[3] = sigmoid_hidden1
        t[4] = output0
        t[5] = sigmoid_output0

        return t

    fn mse_loss(self, y: Float64, y_true: Float64) -> Float64:
        return (y - y_true) ** 2

    fn derivation_sigmoid_activation_function(self, x: Float64) -> Float64:
        return self.sigmoid_activation_function(x) *(1-self.sigmoid_activation_function(x))

    fn fit(self, X: Array2D, Y:Array, learning_rate:Float64, epochs: Int):
        for i in range(epochs):
            for j in range(X.rows()):
                let y = self.feed_forward(X[j, 0], X[j, 1], False)
                let hidden0 = y[0]
                let sigmoid_hidden0 = y[1]
                let hidden1 = y[2]
                let sigmoid_hidden1 = y[3]
                let output0 = y[4]
                let sigmoid_output0 = y[5]

                let derivation_weight_0 = self.weights[0]* self.derivation_sigmoid_activation_function(hidden0)
                let derivation_weight_1 = self.weights[1] * self.derivation_sigmoid_activation_function(hidden0)

                let derivation_weight_2 = self.weights[2]* self.derivation_sigmoid_activation_function(hidden1)
                let derivation_weight_3 = self.weights[3] * self.derivation_sigmoid_activation_function(hidden1)

                let derivation_weight_4 = sigmoid_hidden0 * self.derivation_sigmoid_activation_function(output0)
                let derivation_weight_5 = sigmoid_hidden1 * self.derivation_sigmoid_activation_function(output0)

                let derivation_bias_0 = self.derivation_sigmoid_activation_function(hidden0)
                let derivation_bias_1 = self.derivation_sigmoid_activation_function(hidden1)
                let derivation_bias_2 = self.derivation_sigmoid_activation_function(output0)

                let derivation_hidden_0 = self.weights[4] * self.derivation_sigmoid_activation_function(output0)
                let derivation_hidden_1 = self.weights[5] * self.derivation_sigmoid_activation_function(output0)

                let derivation_mean_square_error = -2 * (Y[j] - y[5])

                self.weights[0] -= learning_rate* derivation_mean_square_error * derivation_hidden_0 * derivation_weight_0
                self.weights[1] -= learning_rate* derivation_mean_square_error * derivation_hidden_0 * derivation_weight_1
                self.weights[2] -= learning_rate* derivation_mean_square_error * derivation_hidden_1 * derivation_weight_2
                self.weights[3] -= learning_rate* derivation_mean_square_error * derivation_hidden_1 * derivation_weight_3

                self.weights[4] -= learning_rate * derivation_mean_square_error * derivation_weight_4
                self.weights[5] -= learning_rate * derivation_mean_square_error * derivation_weight_5

                self.bias[0] -= learning_rate * derivation_mean_square_error * derivation_hidden_0 * derivation_bias_0
                self.bias[1] -= learning_rate * derivation_mean_square_error * derivation_hidden_1 * derivation_bias_1
                self.bias[2]  -= learning_rate * derivation_mean_square_error *  derivation_bias_2

                if i %10 == 0:
                    var mse: Float64 = 0.0
                    for j in range(X.rows()):
                        let y = self.feed_forward(X[j, 0], X[j, 1], True)
                        mse += self.mse_loss(y[0], Y[j])

                        print(X[j, 0].__int__(), X[j, 1].__int__(), ((y[0] > 0.5).__int__()))

                        print( "Epoch ", i, " loss = ", mse/X.rows())




fn main():

    seed(now())
    let X: Array2D = Array2D(4, 2)
    let Y: Array = Array(4,1)

    # 0 And 0 -> 0
    # 0 And 1 -> 0
    # 1 And 0 -> 0
    # 1 And 1 -> 1

    X[0,0] = 0
    X[0,1] = 0
    Y[0] = 0

    X[1,0] = 0
    X[1,1] = 1
    Y[1] = 0

    X[2,0] = 1
    X[2,1] = 0
    Y[2] = 0

    X[3,0] = 1
    X[3,1] = 1
    Y[3] = 1

    let network = NeuralNetwork()
    network.fit(X, Y, 0.1, 10000)

    print("Predictions")
    for i in range(4):
        let result = network.feed_forward(X[i, 0], X[i, 1])

        print(X[i, 0].__int__(), X[i, 1].__int__(), (result[0] > 0.5).__int__())