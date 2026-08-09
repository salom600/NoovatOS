/* NovatOS SDDM Theme — minimal QML, dark background, centered login */
import QtQuick 2.15
import SddmComponents 2.0

Rectangle {
    width: 640
    height: 480
    color: "#0a1f3c"

    Image {
        source: "background.jpg"
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        opacity: 0.7
    }

    Rectangle {
        anchors.centerIn: parent
        width: 360
        height: 320
        color: "#14141f"
        opacity: 0.92
        radius: 12

        Column {
            anchors.centerIn: parent
            spacing: 18

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "NovatOS"
                color: "#4cc2ff"
                font.pixelSize: 36
                font.bold: true
            }

            Text {
                id: clock
                anchors.horizontalCenter: parent.horizontalCenter
                color: "white"
                font.pixelSize: 22
                text: Qt.formatDateTime(new Date(), "hh:mm")

                Timer {
                    interval: 1000
                    running: true
                    repeat: true
                    onTriggered: clock.text = Qt.formatDateTime(new Date(), "hh:mm:ss")
                }
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                color: "#a0a0a0"
                font.pixelSize: 14
                text: Qt.formatDateTime(new Date(), "dddd, MMMM d")
            }

            TextField {
                id: username
                anchors.horizontalCenter: parent.horizontalCenter
                width: 260
                height: 38
                placeholderText: "Username"
                color: "white"
                font.pixelSize: 14
                horizontalAlignment: TextInput.AlignHCenter
                background: Rectangle { color: "#1f1f2e"; radius: 6; border.color: "#3f3f46"; border.width: 1 }

                Keys.onReturnPressed: password.forceActiveFocus()
            }

            TextField {
                id: password
                anchors.horizontalCenter: parent.horizontalCenter
                width: 260
                height: 38
                placeholderText: "Password"
                echoMode: TextInput.Password
                color: "white"
                font.pixelSize: 14
                horizontalAlignment: TextInput.AlignHCenter
                background: Rectangle { color: "#1f1f2e"; radius: 6; border.color: "#3f3f46"; border.width: 1 }

                Keys.onReturnPressed: loginButton.clicked()
            }

            Rectangle {
                id: loginButton
                anchors.horizontalCenter: parent.horizontalCenter
                width: 260
                height: 38
                color: "#0067c0"
                radius: 6

                property bool clicked: false

                Text {
                    anchors.centerIn: parent
                    text: "Sign in"
                    color: "white"
                    font.pixelSize: 14
                    font.bold: true
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        sddm.login(username.text, password.text)
                    }
                }
            }

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 8

                ComboBox {
                    id: session
                    width: 160
                    height: 32
                    model: sessions
                    color: "white"
                    background: Rectangle { color: "#1f1f2e"; radius: 4; border.color: "#3f3f46"; border.width: 1 }
                }

                Rectangle {
                    width: 90; height: 32; color: "#1f1f2e"; radius: 4
                    border.color: "#3f3f46"; border.width: 1
                    Text { anchors.centerIn: parent; text: "Power Off"; color: "#cdd6f4"; font.pixelSize: 12 }
                    MouseArea { anchors.fill: parent; onClicked: sddm.powerOff() }
                }

                Rectangle {
                    width: 70; height: 32; color: "#1f1f2e"; radius: 4
                    border.color: "#3f3f46"; border.width: 1
                    Text { anchors.centerIn: parent; text: "Reboot"; color: "#cdd6f4"; font.pixelSize: 12 }
                    MouseArea { anchors.fill: parent; onClicked: sddm.reboot() }
                }
            }
        }
    }

    Connections {
        target: sddm
        onLoginFailed: {
            password.text = ""
            password.forceActiveFocus()
        }
    }
}
