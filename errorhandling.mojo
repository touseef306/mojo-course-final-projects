from python import Python

fn main():
    try:
        with open("text.html", 'r') as file:
            print(file.read_bytes())

        raise Error("File not found")
    except:
        print("error while reading the file")
    finally:
        print("closing the file")
        
