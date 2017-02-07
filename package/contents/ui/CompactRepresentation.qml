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
import org.kde.plasma.components 2.0 as PlasmaComponents

Item {
    id: compactRepresentation
    
    property double itemWidth:  parent === null ? 0 : vertical ? parent.width : parent.height
    property double itemHeight: itemWidth
    
    Layout.preferredWidth: itemWidth
    Layout.preferredHeight: itemHeight
    
    property double fontPixelSize: itemWidth * 0.72
    property int temperatureIncrement: plasmoid.configuration.manualTemperatureStep
    property int temperatureMin: 1000
    property int temperatureMax: 25000

    property bool textColorLight: ((theme.textColor.r + theme.textColor.g + theme.textColor.b) / 3) > 0.5
    
    PlasmaComponents.Label {
        id: bulbIcon
        anchors.centerIn: parent
        
        font.family: 'FontAwesome'
        text: '\uf0eb'
        
        color: active ? theme.textColor : (textColorLight ? Qt.tint(theme.textColor, '#80000000') : Qt.tint(theme.textColor, '#80FFFFFF'))
        font.pixelSize: fontPixelSize
        font.pointSize: -1
    }
    
    PlasmaComponents.Label {
        id: manualIcon
        anchors.right: parent.right
        anchors.rightMargin: parent.width * 0.2
        anchors.bottom: parent.bottom
        anchors.bottomMargin: parent.height * 0.1
        
        font.family: 'FontAwesome'
        text: '\uf04c'
        
        color: textColorLight ? Qt.tint(theme.textColor, '#80FFFF00') : Qt.tint(theme.textColor, '#80FF3300')
        font.pixelSize: fontPixelSize * 0.3
        font.pointSize: -1
        verticalAlignment: Text.AlignBottom
        
        visible: manualEnabled
    }
    
    MouseArea {
        anchors.fill: parent
        
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton
        
        onWheel: {
            if (!manualEnabled) {
                manualTemperature = manualStartingTemperature
                redshiftDS.connectedSources.length = 0
                manualEnabled = true
                previouslyActive = active
                active = false
            }
            if (redshiftDS.connectedSources.length > 0) {
                return
            }
            if (wheel.angleDelta.y > 0) {
                // wheel up
                manualTemperature += temperatureIncrement
                if (manualTemperature > temperatureMax) {
                    manualTemperature = temperatureMax
                }
            } else {
                // wheel down
                manualTemperature -= temperatureIncrement
                if (manualTemperature < temperatureMin) {
                    manualTemperature = temperatureMin
                }
            }
            redshiftDS.connectedSources.push(redshiftOneTimeCommand)
        }
        
        onClicked: {
            if (!manualEnabled) {
                toggleRedshift()
                return
            }
            
            manualEnabled = false
            if (previouslyActive) {
                toggleRedshift()
            } else {
                stopRedshift()
            }
        }
    }
    
}
