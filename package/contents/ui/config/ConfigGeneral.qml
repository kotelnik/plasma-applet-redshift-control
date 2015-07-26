import QtQuick 2.2
import QtQuick.Controls 1.3
import QtQuick.Layouts 1.0
import org.kde.plasma.core 2.0 as PlasmaCore

Item {
    
    property alias cfg_autostart: autostart.checked

    GridLayout {
        Layout.fillWidth: true
        columns: 1
        
        CheckBox {
            id: autostart
            text: i18n('Autostart')
        }
    }
    
}
