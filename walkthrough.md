# Walkthrough - Qt5 to Qt6 Adaptation Toolkit

I have created a compile-time adaptation toolkit that automatically upgrades Qt5 code to Qt6. The solution consists of two repositories: a core CLI toolkit and a GitHub Action.

## Core Toolkit: `qt-upgrader`

The `qt-upgrader` repository contains a Python-based CLI tool that applies migration rules to source code.

*   **Repository**: [https://github.com/AMDphreak/qt-upgrader](https://github.com/AMDphreak/qt-upgrader)
*   **Ruleset**: Uses a JSON5 ruleset to handle complex migrations like:
    *   `PyQt5` -> `PyQt6` module renames.
    *   Moving `QAction` from `QtWidgets` to `QtGui`.
    *   Translating enums (e.g., `Qt.AlignLeft` -> `Qt.AlignmentFlag.AlignLeft`).
    *   Renaming functions (e.g., `byteCount()` -> `sizeInBytes()`).
*   **CLI Usage**:
    ```powershell
    # Upgrade a directory
    qt-upgrader ./src
    ```

## GitHub Action: `qt-upgrader-action`

The `qt-upgrader-action` repository provides a wrapper around the toolkit for use in CI workflows.

*   **Repository**: [https://github.com/AMDphreak/qt-upgrader-action](https://github.com/AMDphreak/qt-upgrader-action)
*   **Example Workflow**:
    ```yaml
    - name: Upgrade Qt5 to Qt6
      uses: AMDphreak/qt-upgrader-action@main
      with:
        path: './src'
    ```

## Verification Results

I verified the toolkit using unit tests that simulate common Qt5 to Qt6 migration scenarios:

```python
def test_pyqt_imports(engine):
    code = "from PyQt5.QtCore import QObject, pyqtSignal"
    expected = "from PyQt6.QtCore import QObject, pyqtSignal"
    assert engine.apply_rules(code) == expected

def test_qaction_move(engine):
    code_v6 = "from PyQt6.QtWidgets import QAction"
    result = engine.apply_rules(code_v6)
    assert "from PyQt6.QtGui import QAction" in result
```

All 5 tests passed successfully.

## Next Steps

1.  **Tag Releases**: You may want to tag a `v1` release in both repositories for stable usage.
2.  **Organization Transfers**: If you prefer these in a specific organization, you can use `gh api` to transfer them.
3.  **Advanced Rules**: For more complex migrations (like event handling changes), you can add custom regex rules to [qt5_to_qt6.json5](file:///Z:/code/github.com/AMDphreak/qt-upgrader/src/qt_upgrader/rules/qt5_to_qt6.json5).
