import sys
from PyQt4 import QtGui, QtCore

class MyWindow(QtGui.QMainWindow):
    def __init__(self):
        super(MyWindow, self).__init__()
        self.button = QtGui.QPushButton("Click me", self)
        self.connect(self.button, QtCore.SIGNAL("clicked()"), self.on_click)
        self.setCentralWidget(self.button)

    def on_click(self):
        print("Clicked!")

if __name__ == "__main__":
    app = QtGui.QApplication(sys.argv)
    win = MyWindow()
    win.show()
    sys.exit(app.exec_())
