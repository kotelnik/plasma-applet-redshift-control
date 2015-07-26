import QtQuick 2.2
import QtQuick.Controls 1.3
import QtQuick.Layouts 1.0
import org.kde.plasma.core 2.0 as PlasmaCore

Item {
    width: childrenRect.width
    height: childrenRect.height

    property alias cfg_latitude: latitude.value
    property alias cfg_longitude: longitude.value
    property alias cfg_dayTemperature: dayTemperature.value
    property alias cfg_nightTemperature: nightTemperature.value
    
    PlasmaCore.DataSource {
        id: geolocationDS
        engine: 'geolocation'
        
        property string locationSource: 'location'
        
        connectedSources: []
        
        onNewData: {
            print('geolocation: ' + data.latitude)
            latitude.value = data.latitude
            longitude.value = data.longitude
        }
    }
    
    GridLayout {
        Layout.fillWidth: true
        columns: 3
        
        Label {
            text: i18n('Latitude:')
            Layout.alignment: Qt.AlignRight
        }
        SpinBox {
            id: latitude
            decimals: 7
            stepSize: 1
            minimumValue: -90
            maximumValue: 90
            
            Layout.preferredWidth: 150
        }
        
        Button {
            text: i18n('Locate')
            tooltip: 'This will use Mozilla Location Service exposed natively in KDE'
            onClicked: {
                geolocationDS.connectedSources.length = 0
                geolocationDS.connectedSources.push(geolocationDS.locationSource)
            }
            Layout.rowSpan: 2
        }
        
        Label {
            text: i18n('Longitude:')
            Layout.alignment: Qt.AlignRight
        }
        SpinBox {
            id: longitude
            decimals: 7
            stepSize: 1
            minimumValue: -180
            maximumValue: 180
            
            Layout.preferredWidth: 150
        }
        
        Item {
            width: 2
            height: 10
            Layout.columnSpan: 3
        }
        
        Label {
            text: i18n("Day temperature:")
            Layout.alignment: Qt.AlignRight
        }
        SpinBox {
            id: dayTemperature
            decimals: 0
            stepSize: 250
            minimumValue: 1000
            maximumValue: 25000
            Layout.columnSpan: 2
        }
        
        Label {
            text: i18n("Night temperature:")
            Layout.alignment: Qt.AlignRight
        }
        SpinBox {
            id: nightTemperature
            decimals: 0
            stepSize: 250
            minimumValue: 1000
            maximumValue: 25000
            Layout.columnSpan: 2
        }

    }
    
}
