/* ==========================================================================
   ≡quivalence Ecosystem Landing Page JavaScript
   Drives interactive migration preview, tabs, and mobile navigation.
   ========================================================================== */

document.addEventListener('DOMContentLoaded', () => {
  
  // 1. Mobile Menu Toggle
  const menuToggle = document.getElementById('mobile-menu-toggle');
  const mainNav = document.getElementById('main-nav');

  if (menuToggle && mainNav) {
    menuToggle.addEventListener('click', () => {
      mainNav.classList.toggle('open');
      menuToggle.classList.toggle('active');
      
      // Simple toggle animation for the hamburger bar
      const spans = menuToggle.querySelectorAll('span');
      if (menuToggle.classList.contains('active')) {
        spans[0].style.transform = 'rotate(45deg) translate(5px, 5px)';
        spans[1].style.opacity = '0';
        spans[2].style.transform = 'rotate(-45deg) translate(5px, -5px)';
      } else {
        spans[0].style.transform = 'none';
        spans[1].style.opacity = '1';
        spans[2].style.transform = 'none';
      }
    });
  }

  // 2. Interactive Sandbox Data
  const sandboxData = {
    pyqt: {
      title: "PyQt5 to PyQt6 Migration",
      original: `# PyQt5 style imports and widgets
from PyQt5.QtWidgets import QApplication, QMainWindow, QAction
from PyQt5.QtCore import Qt

app = QApplication([])
window = QMainWindow()
action = QAction("&Exit", window)
action.setShortcutContext(Qt.WindowShortcut)`,
      adapted: `# PyQt6 style imports and actions
from PyQt6.QtWidgets import QApplication, QMainWindow
from PyQt6.QtGui import QAction
from PyQt6.QtCore import Qt

app = QApplication([])
window = QMainWindow()
action = QAction("&Exit", window)
action.setShortcutContext(Qt.ShortcutContext.WindowShortcut)`
    },
    paths: {
      title: "Linux to Windows Path Mapping",
      original: `# Abstract OS layout paths on Linux
intent lib_dir {
  linux/ubuntu/22.04: "/usr/lib/x86_64-linux-gnu"
  linux/fedora/38:    "/usr/lib64"
}

intent config_dir {
  linux: "~/.config"
}`,
      adapted: `# Abstract OS layout paths mapped to Windows
intent lib_dir {
  windows: "C:\\Program Files\\Common Files"
}

intent config_dir {
  windows: "%APPDATA%"
}`
    },
    custom: {
      title: "Lightweight SDL Adaptation Rule",
      original: `// Match PyQt5 enum shortcuts and map to PyQt6
rule "PyQt5-to-PyQt6-Enums" {
  replace "Qt.WindowShortcut" "Qt.ShortcutContext.WindowShortcut"
  replace "from PyQt5.QtCore import Qt" "from PyQt6.QtCore import Qt"
}`,
      adapted: `// Applying: PyQt5-to-PyQt6-Enums
// Status: COMPLETED in 3.4ms
// Replacement mappings applied to your source files:
- from PyQt5.QtCore import Qt
+ from PyQt6.QtCore import Qt
- Qt.WindowShortcut
+ Qt.ShortcutContext.WindowShortcut`
    }
  };

  // Sandbox Widgets Elements
  const sandboxWidget = document.getElementById('sandbox-widget');
  const panelTitle = document.getElementById('sandbox-panel-title');
  const codeOriginal = document.getElementById('code-original');
  const codeAdapted = document.getElementById('code-adapted');
  const btnRun = document.getElementById('btn-run-sandbox');
  const outputPanel = codeAdapted.closest('.panel-output');
  const optionButtons = document.querySelectorAll('.sandbox-option');

  let currentTarget = 'pyqt';

  // Function to load target ruleset
  function loadTarget(target) {
    currentTarget = target;
    const data = sandboxData[target];
    
    panelTitle.textContent = data.title;
    codeOriginal.textContent = data.original;
    codeAdapted.textContent = data.original; // Reset output panel to original to await "Apply"
    
    optionButtons.forEach(btn => btn.classList.remove('active'));
    document.getElementById(`option-${target}`).classList.add('active');
  }

  // Bind option clicks
  optionButtons.forEach(btn => {
    btn.addEventListener('click', (e) => {
      const target = btn.dataset.target;
      loadTarget(target);
    });
  });

  // Apply adaptation rules animation
  if (btnRun && codeAdapted && outputPanel) {
    btnRun.addEventListener('click', () => {
      outputPanel.classList.add('updating');
      
      // Simulate adaptation resolve delay (stone/graphite tactile response)
      setTimeout(() => {
        const data = sandboxData[currentTarget];
        codeAdapted.textContent = data.adapted;
        outputPanel.classList.remove('updating');
        
        // Add subtle flash animation
        codeAdapted.style.animation = 'none';
        setTimeout(() => {
          codeAdapted.style.animation = 'glowPulse 0.8s ease-out';
        }, 10);
      }, 350);
    });
  }

  // Add glowPulse keyframes to stylesheet dynamically for sandbox
  const styleSheet = document.createElement("style");
  styleSheet.innerText = `
    @keyframes glowPulse {
      0% { color: var(--accent); text-shadow: 0 0 12px rgba(var(--accent-rgb), 0.25); }
      100% { color: var(--text-secondary); text-shadow: none; }
    }
  `;
  document.head.appendChild(styleSheet);

  // Initialize first selection
  if (sandboxWidget) {
    loadTarget('pyqt');
  }

  // 3. Installation Tab Switcher
  const tabButtons = document.querySelectorAll('.tab-btn');
  const tabPanes = document.querySelectorAll('.tab-pane');

  tabButtons.forEach(btn => {
    btn.addEventListener('click', () => {
      const activeTab = btn.dataset.tab;
      
      tabButtons.forEach(b => b.classList.remove('active'));
      tabPanes.forEach(p => p.classList.remove('active'));
      
      btn.classList.add('active');
      document.getElementById(`tab-${activeTab}`).classList.add('active');
    });
  });

});
