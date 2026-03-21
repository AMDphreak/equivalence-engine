from PyQt6.QtGui import QApplication, QWidget, QVBoxLayout, QPushButton, QAction
from PyQt6.QtCore import Qt

class MyWidget(QWidget):
    def __init__(self):
        super().__init__()
        self.layout = QVBoxLayout()
        self.btn = QPushButton("Click me")
        self.layout.addWidget(self.btn)
        self.setLayout(self.layout)
        
        self.action = QAction("Test Action", self)
        
    def check(self):
        if self.btn.isChecked() == Qt.CheckState.Checked:
            print("Checked")
        self.close()

if __name__ == "__main__":
    app = QApplication([])
    w = MyWidget()
    w.show()
    app.exec()
