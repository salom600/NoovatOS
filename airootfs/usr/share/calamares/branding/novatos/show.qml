/* NovatOS Calamares QSS — dark, blue accent, Windows-11-ish installer look */

QMainWindow,
QWidget {
    background-color: #0a1f3c;
    color: #ffffff;
    font-family: "Roboto", "Segoe UI", sans-serif;
    font-size: 13px;
}

QPushButton {
    background-color: #0067c0;
    color: white;
    border: none;
    border-radius: 6px;
    padding: 8px 18px;
    min-width: 90px;
}

QPushButton:hover {
    background-color: #2b88d8;
}

QPushButton:pressed {
    background-color: #005494;
}

QPushButton:disabled {
    background-color: #3f3f46;
    color: #999999;
}

QPushButton#calamares-toggle {
    background: transparent;
    color: #4cc2ff;
}

QLineEdit,
QTextEdit,
QComboBox,
QSpinBox {
    background-color: #14141f;
    color: #ffffff;
    border: 1px solid #3f3f46;
    border-radius: 4px;
    padding: 6px;
}

QLineEdit:focus {
    border-color: #4cc2ff;
}

QListWidget,
QTreeWidget {
    background-color: #14141f;
    color: #ffffff;
    border: 1px solid #3f3f46;
    border-radius: 4px;
}

QListWidget::item:selected,
QTreeWidget::item:selected {
    background-color: #0067c0;
}

QProgressBar {
    background-color: #14141f;
    border: 1px solid #3f3f46;
    border-radius: 4px;
    text-align: center;
    color: #ffffff;
}

QProgressBar::chunk {
    background-color: #4cc2ff;
    border-radius: 3px;
}

QLabel {
    color: #ffffff;
}

QLabel#calamares-title {
    font-size: 22px;
    font-weight: bold;
    color: #4cc2ff;
}

QGroupBox {
    border: 1px solid #3f3f46;
    border-radius: 6px;
    margin-top: 12px;
    padding-top: 14px;
}

QGroupBox::title {
    color: #4cc2ff;
    subcontrol-origin: margin;
    left: 12px;
    padding: 0 6px;
}

QCheckBox {
    color: #cdd6f4;
}

QCheckBox::indicator {
    width: 16px;
    height: 16px;
    border: 1px solid #4cc2ff;
    border-radius: 3px;
    background: transparent;
}

QCheckBox::indicator:checked {
    background: #4cc2ff;
}

QScrollBar:vertical {
    background: #14141f;
    width: 10px;
}

QScrollBar::handle:vertical {
    background: #3f3f46;
    border-radius: 5px;
}
