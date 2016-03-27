import QtQuick 2.2
import QtQuick.Controls 1.3
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore

Item {
    
    property alias cfg_autostart: autostart.checked
    property alias cfg_smoothTransitions: smoothTransitions.checked
    property alias cfg_manualTemperatureStep: manualTemperatureStep.value

    Label {
        text: i18n('Plasmoid version') + ': 1.0.16'
        anchors.right: parent.right
    }
    
    GridLayout {
        Layout.fillWidth: true
        columns: 2
        
        CheckBox {
            id: autostart
            text: i18n('Autostart')
            Layout.columnSpan: 2
        }
        
        CheckBox {
            id: smoothTransitions
            text: i18n('Smooth transitions')
            Layout.columnSpan: 2
        }
        
        Item {
            width: 2
            height: 10
            Layout.columnSpan: 2
        }
        
        Label {
            text: i18n("Manual temperature step:")
            Layout.alignment: Qt.AlignRight
        }
        SpinBox {
            id: manualTemperatureStep
            decimals: 0
            stepSize: 125
            minimumValue: 25
            maximumValue: 5000
        }
    }
    
}
