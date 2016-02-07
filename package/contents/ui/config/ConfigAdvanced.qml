import QtQuick 2.2
import QtQuick.Controls 1.3
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore

Item {
    
    property alias cfg_geoclueLocationEnabled: geoclueLocationEnabled.checked
    property alias cfg_latitude: latitude.value
    property alias cfg_longitude: longitude.value
    property alias cfg_dayTemperature: dayTemperature.value
    property alias cfg_nightTemperature: nightTemperature.value
    property alias cfg_dayBrightness: dayBrightness.value
    property alias cfg_nightBrightness: nightBrightness.value
    property alias cfg_gammaR: gammaR.value
    property alias cfg_gammaG: gammaG.value
    property alias cfg_gammaB: gammaB.value
    property string cfg_renderMode
    property alias cfg_preserveScreenColour: preserveScreenColour.checked
    
    onCfg_renderModeChanged: {
        print('restore: ' + cfg_renderMode)
        var comboIndex = modeCombo.find(cfg_renderMode)
        print('restore index: ' + comboIndex)
        if (comboIndex > -1) {
            modeCombo.currentIndex = comboIndex
        }
    }
    
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
        columns: 4
        
        Label {
            text: i18n("Location")
            Layout.columnSpan: parent.columns
            font.bold: true
        }
        CheckBox {
            id: geoclueLocationEnabled
            text: i18n('Automatic (geoclue)')
            Layout.columnSpan: parent.columns
        }
        Label {
            text: i18n('Latitude:')
            Layout.alignment: Qt.AlignRight
            enabled: !geoclueLocationEnabled.checked
        }
        SpinBox {
            id: latitude
            decimals: 7
            stepSize: 1
            minimumValue: -90
            maximumValue: 90
            
            Layout.preferredWidth: 150
            enabled: !geoclueLocationEnabled.checked
        }
        
        Button {
            text: i18n('Locate')
            tooltip: 'This will use Mozilla Location Service exposed natively in KDE'
            onClicked: {
                geolocationDS.connectedSources.length = 0
                geolocationDS.connectedSources.push(geolocationDS.locationSource)
            }
            Layout.rowSpan: 2
            Layout.columnSpan: 2
            enabled: !geoclueLocationEnabled.checked
        }
        
        Label {
            text: i18n('Longitude:')
            Layout.alignment: Qt.AlignRight
            enabled: !geoclueLocationEnabled.checked
        }
        SpinBox {
            id: longitude
            decimals: 7
            stepSize: 1
            minimumValue: -180
            maximumValue: 180
            
            Layout.preferredWidth: 150
            enabled: !geoclueLocationEnabled.checked
        }
        
        Item {
            width: 2
            height: 10
            Layout.columnSpan: parent.columns
        }
        
        Label {
            text: i18n("Temperature")
            Layout.columnSpan: 2
            font.bold: true
        }
        Label {
            text: i18n("Brightness")
            Layout.columnSpan: 2
            font.bold: true
        }
        
        Label {
            text: i18n("Day:")
            Layout.alignment: Qt.AlignRight
        }
        SpinBox {
            id: dayTemperature
            decimals: 0
            stepSize: 250
            minimumValue: 1000
            maximumValue: 25000
            Layout.columnSpan: 1
        }
        
        Label {
            text: i18n("Day:")
            Layout.alignment: Qt.AlignRight
        }
        SpinBox {
            id: dayBrightness
            decimals: 2
            stepSize: 0.1
            minimumValue: 0.1
            maximumValue: 1
            Layout.columnSpan: 1
        }
        
        Label {
            text: i18n("Night:")
            Layout.alignment: Qt.AlignRight
        }
        SpinBox {
            id: nightTemperature
            decimals: 0
            stepSize: 250
            minimumValue: 1000
            maximumValue: 25000
            Layout.columnSpan: 1
        }
        
        Label {
            text: i18n("Night:")
            Layout.alignment: Qt.AlignRight
        }
        SpinBox {
            id: nightBrightness
            decimals: 2
            stepSize: 0.1
            minimumValue: 0.1
            maximumValue: 1
            Layout.columnSpan: 1
        }
        
        Item {
            width: 2
            height: 10
            Layout.columnSpan: parent.columns
        }
        Label {
            text: i18n("Gamma")
            Layout.columnSpan: parent.columns
            font.bold: true
        }
        Label {
            text: i18n("RGB:")
            Layout.alignment: Qt.AlignRight
        }
        RowLayout {
            Layout.columnSpan: 3
            
            SpinBox { 
                id:"gammaR"
                decimals: 2
                minimumValue: 0.1
                maximumValue: 10
                stepSize: 0.1
            }
            SpinBox { 
                id:"gammaG"
                decimals: 2
                minimumValue: 0.1
                maximumValue: 10
                stepSize: 0.1
            }
            SpinBox {
                id:"gammaB"
                decimals: 2
                minimumValue: 0.1
                maximumValue: 10
                stepSize: 0.1
            }
        }
        
        Item {
            width: 2
            height: 10
            Layout.columnSpan: parent.columns
        }
        Label {
            text: i18n("Mode")
            Layout.columnSpan: parent.columns
            font.bold: true
        }
        ComboBox {
            id: modeCombo
            Layout.columnSpan: 2
            model: ListModel {
                ListElement {
                    text: 'Automatic'
                    val: ''
                }
                ListElement {
                    text: 'randr'
                    val: 'randr'
                }
                ListElement {
                    text: 'vidmode'
                    val: 'vidmode'
                }
            }
            onCurrentIndexChanged: {
                cfg_renderMode = model.get(currentIndex).val
                print('saved: ' + cfg_renderMode)
            }
        }
        CheckBox {
            id: preserveScreenColour
            Layout.columnSpan: 2
            text: i18n('Preserve screen colour')
            enabled: {
                var mode = modeCombo.model.get(modeCombo.currentIndex).val
                return mode === 'randr' || mode === 'vidmode'
            }
        }

    }
    
}
