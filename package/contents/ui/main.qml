/*
 * Copyright 2015  Martin Kotelnik <clearmartin@seznam.cz>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http: //www.gnu.org/licenses/>.
 */
import QtQuick 2.2
import QtQuick.Layouts 1.1
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore

Item {
    id: main

    anchors.fill: parent

    property bool vertical: (plasmoid.formFactor == PlasmaCore.Types.Vertical)

    property bool active: false
    property bool previouslyActive: false
    property bool startAfterStop: false

    property bool autostart: plasmoid.configuration.autostart
    property bool smoothTransitions: plasmoid.configuration.smoothTransitions

    property bool geoclueLocationEnabled: plasmoid.configuration.geoclueLocationEnabled
    property double latitude: plasmoid.configuration.latitude
    property double longitude: plasmoid.configuration.longitude
    property int dayTemperature: plasmoid.configuration.dayTemperature
    property int nightTemperature: plasmoid.configuration.nightTemperature
    property double dayBrightness: plasmoid.configuration.dayBrightness
    property double nightBrightness: plasmoid.configuration.nightBrightness
    property double gammaR: plasmoid.configuration.gammaR
    property double gammaG: plasmoid.configuration.gammaG
    property double gammaB: plasmoid.configuration.gammaB
    property string renderMode: plasmoid.configuration.renderMode
    property string renderModeString: plasmoid.configuration.renderModeString
    property bool preserveScreenColour: renderMode === 'randr' || renderMode === 'vidmode' ? plasmoid.configuration.preserveScreenColour : false

    property int manualStartingTemperature: 6500
    property int manualTemperature: manualStartingTemperature
    property bool manualEnabled: false
    property int currentTemperature: manualStartingTemperature
    property int manualStartingBrightness: 100
    property int manualBrightness: manualStartingBrightness
    property bool manualEnabledBrightness: false
    property int currentBrightness: manualStartingBrightness

    //
    // terminal commands
    //
    // - parts
    property string brightnessAndGamma: ' -b ' + dayBrightness + ':' + nightBrightness + ' -g ' + gammaR + ':' + gammaG + ':' + gammaB
    property string locationCmdPart: geoclueLocationEnabled ? '' : ' -l ' + latitude + ':' + longitude
    property string modeCmdPart: renderModeString === '' ? '' : ' ' + renderModeString

    // - commands
    property string redshiftCommand: 'redshift' + locationCmdPart + modeCmdPart + ' -t ' + dayTemperature + ':' + nightTemperature + brightnessAndGamma + (smoothTransitions ? '' : ' -r')
    property string redshiftOneTimeBrightnessAndGamma: ' -b ' + (currentBrightness*0.01).toFixed(2) + ':' + (currentBrightness*0.01).toFixed(2) + ' -g ' + gammaR + ':' + gammaG + ':' + gammaB
    property string redshiftOneTimeCommand: 'redshift -O ' + manualTemperature + redshiftOneTimeBrightnessAndGamma + ' -r'
    property string redshiftPrintCommand: 'LANG=C ' + redshiftCommand + ' -p'

    property bool inTray: (plasmoid.parent === null || plasmoid.parent.objectName === 'taskItemContainer')

    Plasmoid.preferredRepresentation: Plasmoid.compactRepresentation
    Plasmoid.compactRepresentation: CompactRepresentation { }

    Component.onCompleted: {
        print('renderModeString: ' + renderModeString)
        if (!inTray) {
            // not in tray
            Plasmoid.fullRepresentation = null
        }
        restartRedshiftIfAutostart()
    }

    function toggleRedshift() {
        if (redshiftDS.connectedSources.length > 0) {
            stopRedshift()
        } else {
            print('enabling redshift with command: ' + redshiftCommand)
            redshiftDS.connectedSources.push(redshiftCommand)
            active = true
        }
    }

    function stopRedshift() {
        print('disabling redshift')
        redshiftDS.connectedSources.length = 0
        redshiftDS.connectedSources.push(redshiftDS.redshiftStopSource)
        active = false
    }

    function restartRedshiftIfAutostart() {
        manualEnabled = false
        startAfterStop = autostart
        stopRedshift()
    }

    onRedshiftCommandChanged: {
        restartRedshiftIfAutostart()
    }

    onRedshiftPrintCommandChanged: {
        redshiftPrintDS.connectedSources.length = 0
        redshiftPrintDS.connectedSources.push(redshiftPrintCommand)
    }

    FontLoader {
        source: '../fonts/fontawesome-webfont-4.3.0.ttf'
    }

    PlasmaCore.DataSource {
        id: redshiftDS
        engine: 'executable'

        property string redshiftStopSource: preserveScreenColour ? 'pkill -USR1 redshift; killall redshift' : 'killall redshift; redshift -x'

        connectedSources: [redshiftStopSource]

        onNewData: {
            if (sourceName === redshiftStopSource) {
                print('clearing connected sources, stop source was: ' + redshiftStopSource)
                connectedSources.length = 0
                if (startAfterStop) {
                    startAfterStop = false
                    toggleRedshift()
                }
                return
            }

            if (data['exit code'] > 0) {
                print('Error running redshift with command: ' + sourceName + '   ...stderr: ' + data.stderr)

                var service = notificationsDS.serviceForSource('notifications')
                var operation = service.operationDescription('createNotification')
                operation.appName = 'Redshift Control'
                operation.appIcon = 'redshift'
                operation.summary = 'Error running Redshift command'
                operation.body = data.stderr
                service.startOperationCall(operation)

                stopRedshift()
                return
            }

            print('process exited with code 0. sourceName: ' + sourceName + ', data: ' + data.stdout)

            if (manualEnabled) {
                connectedSources.length = 0
            }
        }
    }

    PlasmaCore.DataSource {
        id: redshiftPrintDS
        engine: 'executable'
        interval: active ? 10000 : 0

        connectedSources: []

        onNewData: {
            if (data['exit code'] > 0) {
                print('Error running redshift print cmd with command: ' + sourceName + '   ...stderr: ' + data.stderr)
                return
            }

            // example output: "Color temperature: 5930K"
            var matchTemperature = /Color temperature: ([0-9]+)K/.exec(data.stdout)
            // example output: "Brightness: 1.0"
            var matchBrightness = /Brightness: ([0-9]+\.[0-9]+)/.exec(data.stdout)
            if (matchTemperature !== null) {
                currentTemperature = parseInt(matchTemperature[1])
            }
            if (matchBrightness !== null) {
                currentBrightness = parseFloat(matchBrightness[1])*100
            }
        }
    }

    PlasmaCore.DataSource {
        id: notificationsDS
        engine: 'notifications'
        connectedSources: [ 'notifications' ]
    }

    function updateTooltip() {
        var toolTipSubText = ''
        toolTipSubText += '<font size="4">'
        if (active) {
            toolTipSubText += i18n('Turned on') + ', ' + currentTemperature + 'K'
        } else {
            if (manualEnabled) {
                toolTipSubText += i18n('Manual temperature') + ' ' + manualTemperature + 'K | ' + i18n('Brightness') + ' ' + (manualBrightness*0.01).toFixed(2)
            } else {
                toolTipSubText += i18n('Turned off')
            }
        }
        toolTipSubText += '</font>'
        toolTipSubText += '<br />'
        toolTipSubText += '<i>' + i18n('Use left / middle click and wheel to manage screen temperature and brightness') + '</i>'
        toolTipSubText += '<br />'
        if (manualEnabledBrightness) {
            toolTipSubText += i18n('Mouse wheel controls software brightness')
        } else {
            toolTipSubText += i18n('Mouse wheel controls screen temperature')
        }

        Plasmoid.toolTipSubText = toolTipSubText

        plasmoidPassiveTimer.stop()
        plasmoid.status = PlasmaCore.Types.ActiveStatus
        plasmoidPassiveTimer.restart()
    }

    Timer {
        id: plasmoidPassiveTimer
        interval: 20000
        onTriggered: {
            plasmoid.status = PlasmaCore.Types.PassiveStatus
        }
    }

    onActiveChanged: updateTooltip()
    onManualEnabledChanged: updateTooltip()
    onManualTemperatureChanged: updateTooltip()
    onManualBrightnessChanged: updateTooltip()
    onCurrentTemperatureChanged: updateTooltip()

    Plasmoid.toolTipMainText: i18n('Redshift Control')
    Plasmoid.toolTipSubText: ''
    Plasmoid.toolTipTextFormat: Text.RichText
    Plasmoid.icon: 'redshift'

    // NOTE: taken from colorPicker plasmoid
    // prevents the popup from actually opening, needs to be queued
    Timer {
        id: delayedRunShortcutTimer
        interval: 0
        onTriggered: {
            plasmoid.expanded = false
            toggleRedshift()
        }
    }

    Plasmoid.onActivated: {
        delayedRunShortcutTimer.start()
    }

}
