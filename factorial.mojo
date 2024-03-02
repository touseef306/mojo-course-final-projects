fn factorial(n:Int) -> Int:
    if n < 0:
        print("Factorial is not defined for negative numbers")
        return 0
    if n == 0:
        return 1
    else:
        return n * factorial(n-1)


fn main():
    let number: Int = -3
    let result: Int = factorial(number)
    print(result)
