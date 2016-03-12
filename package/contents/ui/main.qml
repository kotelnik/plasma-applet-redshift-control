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
    property bool preserveScreenColour: renderMode === 'randr' || renderMode === 'vidmode' ? plasmoid.configuration.preserveScreenColour : false
    
    property int manualStartingTemperature: 6500
    property int manualTemperature: manualStartingTemperature
    property bool manualEnabled: false
    property int currentTemperature: manualStartingTemperature
    
    property string brightnessAndGamma: ' -b ' + dayBrightness + ':' + nightBrightness + ' -g ' + gammaR + ':' + gammaG + ':' + gammaB
    property string locationCmdPart: geoclueLocationEnabled ? '' : ' -l ' + latitude + ':' + longitude
    property string modeCmdPart: renderMode === '' ? '' : ' -m ' + renderMode + (preserveScreenColour ? ':preserve=1' : '')
    property string redshiftCommand: 'redshift' + locationCmdPart + modeCmdPart + ' -t ' + dayTemperature + ':' + nightTemperature + brightnessAndGamma + (smoothTransitions ? '' : ' -r')
    property string redshiftOneTimeCommand: 'redshift -O ' + manualTemperature + brightnessAndGamma + ' -r'
    property string redshiftPrintCommand: redshiftCommand + ' -p'
    
    property bool inTray: (plasmoid.parent === null || plasmoid.parent.objectName === 'taskItemContainer')
    
    Plasmoid.preferredRepresentation: Plasmoid.compactRepresentation
    Plasmoid.compactRepresentation: CompactRepresentation { }
    Plasmoid.fullRepresentation: CompactRepresentation { }
    
    Component.onCompleted: {
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

        connectedSources: []
        
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
            var match = /Color temperature: ([0-9]+)K/.exec(data.stdout)
            if (match !== null) {
                currentTemperature = parseInt(match[1])
            } else {
                print('redshift print finished with code 0. sourceName: ' + sourceName + ', data: ' + data.stdout + ', but not matched the regex')
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
        toolTipSubText += '<font size="4">' + (active ? 'Turned on, ' + currentTemperature + 'K' : (manualEnabled ? ('Manual temperature ' + manualTemperature + 'K') : 'Turned off')) + '</font>'
        toolTipSubText += '<br />'
        toolTipSubText += '<i>Use middle click and wheel to manage screen temperature</i>'
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
    onCurrentTemperatureChanged: updateTooltip()
    
    Plasmoid.toolTipMainText: i18n('Redshift Control')
    Plasmoid.toolTipSubText: ''
    Plasmoid.toolTipTextFormat: Text.RichText
    Plasmoid.icon: 'redshift'
    
}
