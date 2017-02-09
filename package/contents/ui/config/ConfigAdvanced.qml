import QtQuick 2.2
import QtQuick.Controls 1.3
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore

Item {
    id: advancedConfig

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
    property alias cfg_renderModeScreen: renderModeScreen.text
    property alias cfg_renderModeCard: renderModeCard.text
    property alias cfg_renderModeCrtc: renderModeCrtc.text
    property alias cfg_preserveScreenColour: preserveScreenColour.checked
    property string cfg_renderModeString

    property string versionString: 'N/A'
    property string modeString: ''

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
            tooltip: i18n('This will use Mozilla Location Service exposed natively in KDE')
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
            text: i18n('Temperature')
            Layout.columnSpan: 2
            font.bold: true
        }
        Label {
            text: i18n('Brightness')
            Layout.columnSpan: 2
            font.bold: true
        }

        Label {
            text: i18n('Day:')
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
            text: i18n('Day:')
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
            text: i18n('Night:')
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
            text: i18n('Night:')
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
            text: i18n('Gamma')
            Layout.columnSpan: parent.columns
            font.bold: true
        }
        Label {
            text: i18n('RGB:')
            Layout.alignment: Qt.AlignRight
        }
        RowLayout {
            Layout.columnSpan: 3

            SpinBox { 
                id: 'gammaR'
                decimals: 2
                minimumValue: 0.1
                maximumValue: 10
                stepSize: 0.1
            }
            SpinBox { 
                id: 'gammaG'
                decimals: 2
                minimumValue: 0.1
                maximumValue: 10
                stepSize: 0.1
            }
            SpinBox {
                id: 'gammaB'
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
            text: i18n('Mode')
            Layout.columnSpan: parent.columns
            font.bold: true
        }
        // col 1
        ComboBox {
            id: modeCombo
            model: ListModel {
                ListElement {
                    text: 'Auto'
                    val: ''
                }
                ListElement {
                    text: 'drm'
                    val: 'drm'
                }
                ListElement {
                    text: 'randr'
                    val: 'randr'
                }
                ListElement {
                    text: 'vidmode'
                    val: 'vidmode'
                }
                ListElement {
                    text: 'Manual'
                    val: 'MANUAL'
                }
            }
            onCurrentIndexChanged: {
                cfg_renderMode = model.get(currentIndex).val
                print('saved: ' + cfg_renderMode)
                modeChanged()
            }
        }

        // col 2
        TextField {
            id: renderModeScreen
            placeholderText: i18n('Screen')
            visible: isMode(['randr', 'vidmode'])
            onTextChanged: modeChanged()
        }
        TextField {
            id: renderModeCard
            placeholderText: i18n('Card')
            visible: isMode(['drm', 'card'])
            onTextChanged: modeChanged()
        }
        TextField {
            id: fakeTextField
            opacity: 0
            visible: !renderModeScreen.visible && !renderModeCard.visible
        }

        // col 2
        TextField {
            id: renderModeCrtc
            width: advancedConfig / 8
            placeholderText: i18n('CRTC')
            opacity: isMode(['drm', 'randr']) ? 1 : 0
            onTextChanged: modeChanged()
        }

        // col 4
        CheckBox {
            id: preserveScreenColour
            text: i18n('Preserve screen colour')
            opacity: isMode(['randr', 'vidmode']) ? 1 : 0
            enabled: parseFloat(versionString) >= 1.11
            onCheckedChanged: modeChanged()
        }

        TextField {
            id: modeString
            placeholderText: i18n('Insert custom mode options')
            Layout.columnSpan: parent.columns
            Layout.preferredWidth: parent.width - 5
            enabled: isMode(['MANUAL'])
            visible: !isMode([''])
            onTextChanged: cfg_renderModeString = text
        }

    }

    function modeChanged() {
        switch (cfg_renderMode) {
        case 'drm':
            modeString.text = '-m drm' + (renderModeCard.text.length > 0 ? ':card=' + renderModeCard.text : '') + (renderModeCrtc.text.length > 0 ? ':crtc=' + renderModeCrtc.text : '')
            break
        case 'randr':
            modeString.text = '-m randr' + (renderModeScreen.text.length > 0 ? ':screen=' + renderModeScreen.text : '') + (renderModeCrtc.text.length > 0 ? ':crtc=' + renderModeCrtc.text : '') + (preserveScreenColour.enabled && preserveScreenColour.checked ? ':preserve=1' : '')
            break
        case 'vidmode':
            modeString.text = '-m vidmode' + (renderModeScreen.text.length > 0 ? ':screen=' + renderModeScreen.text : '') + (preserveScreenColour.enabled && preserveScreenColour.checked ? ':preserve=1' : '')
            break
        default:
            modeString.text = ''
        }
        cfg_renderModeString = modeString.text
    }

    function isMode(modes) {
        var currentMode = modeCombo.model.get(modeCombo.currentIndex).val
        return modes.some(function (iterMode) {
            return currentMode === iterMode
        })
    }

    Label {
        id: versionStringLabel
        text: versionString
        anchors.right: parent.right
    }
    Label {
        text: i18n('Redshift version') + ': '
        font.bold: true
        anchors.right: versionStringLabel.left
    }

    PlasmaCore.DataSource {
        id: getOptionsDS
        engine: 'executable'

        connectedSources: ['redshift -V']

        onNewData: {
            connectedSources.length = 0
            if (data['exit code'] > 0) {
                print('Error running redshift with command: ' + sourceName + '   ...stderr: ' + data.stderr)
                return
            }
            versionString = data.stdout.split(' ')[1]
        }
    }

}
