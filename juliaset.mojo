from math import abs, ComplexSIMD
from python import Python

@register_passable
struct Juliaset:
    var max_iter:Int
    var width:Int
    var height:Int
    var cmplx: ComplexSIMD[DType.float64, 1]

    fn __init__(max_iter:Int,width:Int, height:Int, cmplx: ComplexSIMD[DType.float64, 1]) -> Self:
        return Self{max_iter:max_iter,width:width,height:height,cmplx:cmplx}


    fn calculate(self, x:Float64,y:Float64 ) -> Int:
        var z: ComplexSIMD[DType.float64, 1] = ComplexSIMD(x,y)

        var n:Int = 0

        while abs(z) <= 2 and n < self.max_iter:
            z = z*z + self.cmplx

            n+=1

        return n

    fn generateImage(self) raises:
        let X_START: Int = -2
        let X_END: Int = 2

        let Y_START: Int = -2
        let Y_END: Int = 2


        let image: PythonObject = Python.import_module("PIL.Image")
        let ImageDraw: PythonObject = Python.import_module("PIL.ImageDraw")
        let im: PythonObject = image.new('RGB',(self.width,self.height),(0,0,0))
        let draw: PythonObject = ImageDraw.Draw(im)

        for x in range(self.width):
            for y in range(self.height):
                let normalized_x: SIMD[DType.float64,1] = x / self.width
                let normalized_y: SIMD[DType.float64, 1] = y / self.height

                let mapped_x: SIMD[DType.float64,1] = X_START +normalized_x * (X_END-X_START)
                let mapped_y: SIMD[DType.float64,1]= Y_START + normalized_y * (Y_END-Y_START)

                let m: Int = self.calculate(mapped_x,mapped_y)

                # var color: Tuple[Int, Int, Int] = (0,255,0)

                # if m == self.max_iter:
                #     color = (255,255,255)
                # else:
                #     color =(255,0,0)

                var color: Tuple[Int, Int, Int] = (0,0,0)

                if m == self.max_iter:
                    color = (0,0,0)
                else:
                    let factor = Float16(m) / Float16(self.max_iter)

                    let red = Float16(factor *255)
                    let green = Float16(factor * factor * 255)

                    color =(red.to_int(),green.to_int(),0)


                _ = draw.point([x,y],color)

        _ = im.save("juliaset.png",'PNG')


fn main() raises:
    let max_iter = 50
    let height = 600
    let width =800
    let creal: Float64 = 0.285
    let cimag: Float64 = 0.01

    let complx: ComplexSIMD[DType.float64, 1] = ComplexSIMD(creal,cimag)

    let juliaset = Juliaset(max_iter,width,height,complx)
    _  = juliaset.generateImage()