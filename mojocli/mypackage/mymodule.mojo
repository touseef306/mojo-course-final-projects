
struct Name:
    var first: String
    var last: String

    fn __init__(inout self, first: String, last: String):
        self.first = first
        self.last = last

    fn display(self):
        print(self.first, self.last)