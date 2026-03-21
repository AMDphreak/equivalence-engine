import pytest
from qt_upgrader.engine import MigrationEngine
import json5
from pathlib import Path

@pytest.fixture
def engine():
    rules_path = Path(__file__).parent.parent / "src" / "qt_upgrader" / "rules" / "qt5_to_qt6.json5"
    with open(rules_path, "r", encoding="utf-8") as f:
        rules_data = json5.load(f)
    return MigrationEngine(rules_data.get("rules", []))

def test_pyqt_imports(engine):
    code = "from PyQt5.QtCore import QObject, pyqtSignal"
    expected = "from PyQt6.QtCore import QObject, pyqtSignal"
    assert engine.apply_rules(code) == expected

def test_qaction_move(engine):
    code = "from PyQt5.QtWidgets import QAction"
    # Note: our regex assumes PyQt6 has been applied first
    code_v6 = "from PyQt6.QtWidgets import QAction"
    result = engine.apply_rules(code_v6)
    assert "from PyQt6.QtGui import QAction" in result
    assert "from PyQt6.QtWidgets import" in result

def test_enum_alignment(engine):
    code = "label.setAlignment(Qt.AlignLeft | Qt.AlignTop)"
    expected = "label.setAlignment(Qt.AlignmentFlag.AlignLeft | Qt.AlignmentFlag.AlignTop)"
    assert engine.apply_rules(code) == expected

def test_function_rename(engine):
    code = "size = img.byteCount()"
    expected = "size = img.sizeInBytes()"
    assert engine.apply_rules(code) == expected

def test_exec_rename(engine):
    code = "dialog.exec_()"
    expected = "dialog.exec()"
    assert engine.apply_rules(code) == expected

def test_qregexp_rename(engine):
    code = "rx = QRegExp('^[0-9]+$')"
    expected = "rx = QRegularExpression('^[0-9]+$')"
    assert engine.apply_rules(code) == expected

def test_complex_enum(engine):
    code = "slider.setOrientation(Qt.Horizontal)"
    expected = "slider.setOrientation(Qt.Orientation.Horizontal)"
    assert engine.apply_rules(code) == expected

def test_event_pos(engine):
    code = "p = event.pos()"
    expected = "p = event.position()"
    assert engine.apply_rules(code) == expected
