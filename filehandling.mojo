fn main() raises:
    var handler: FileHandle =open("test.txt",'r')
    let str : String = handler.read()
    print(str)
    handler.close()