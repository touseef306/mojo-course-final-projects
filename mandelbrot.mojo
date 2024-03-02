from math import ComplexSIMD
from python import Python
@register_passable
struct Mandelbrot:
    var max_iter: Int
    var width: Int
    var height: Int

    fn __init__(max_iter:Int,width:Int, height:Int) -> Self:
        return Self{max_iter:max_iter, width:width,height:height}

    fn calculate(self, c:ComplexSIMD[DType.float64,1]) -> Int:
        var z:ComplexSIMD[DType.float64,1] = c

        for i in range(self.max_iter):
            z = z*z + c
            if z.squared_norm() > 4:
                return i
        return self.max_iter

    
    fn generateImage(self) raises:
        let RE_START:Int = -2
        let RE_END:Int = 1
        let IM_START: Int = -1
        let IM_END:Int = 1

        let image: PythonObject = Python.import_module("PIL.Image")
        let ImageDraw: PythonObject = Python.import_module("PIL.ImageDraw")


        let im: PythonObject = image.new('RGB', (self.width, self.height), (0,0,0))
        let draw: PythonObject = ImageDraw.Draw(im)


        for x in range(0, self.width):
            for y in range(0, self.height):
                let c: ComplexSIMD[DType.float64,1] = ComplexSIMD(RE_START + (x / self.width) * ( RE_END - RE_START), (IM_START + (y/self.height) * (IM_END- IM_START)))

                let m: Int = self.calculate(c)

                # var color: Tuple[Int, Int, Int] = (0,255,0)

                # if m == self.max_iter:
                #     color = (255,255,255)
                # else:
                #     color = (255,0,0)

                var color: Tuple[Int, Int, Int] = (0,0,0)

                if m == self.max_iter:
                    color = (0,0,0)
                else:
                    let factor = Float16(m) / Float16(self.max_iter)
                    let red = Float16(factor *255)
                    let green = Float16(255 * factor * factor)

                    color= (red.to_int(), green.to_int(), 0)
                _ = draw.point([x,y],(color))

        
        _ = im.save("mandelbrot.png", 'PNG')


fn main() raises:
    let max_iter = 25
    let height = 1920
    let width = 1080

    let mandelbrot = Mandelbrot(max_iter, height,width)

    _= mandelbrot.generateImage()