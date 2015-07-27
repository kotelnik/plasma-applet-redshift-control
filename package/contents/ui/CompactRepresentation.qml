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
import QtGraphicalEffects 1.0
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import QtQuick.Controls 1.3

Item {
    id: compactRepresentation
    
    property double itemWidth:  parent === null ? 0 : vertical ? parent.width : parent.height
    property double itemHeight: itemWidth
    
    Layout.preferredWidth: itemWidth
    Layout.preferredHeight: itemHeight
    
    property double fontPointSize: itemWidth * 0.65
    property int temperatureIncrement: 500
    property int temperatureMin: 1000
    property int temperatureMax: 25000
    
    Label {
        id: bulbIcon
        anchors.centerIn: parent
        
        font.family: 'FontAwesome'
        text: '\uf0eb'
        
        color: active ? '#FF3300' : theme.textColor
        font.pointSize: fontPointSize
    }
    
    Label {
        id: manualIcon
        anchors.right: parent.right
        anchors.rightMargin: parent.width * 0.2
        anchors.bottom: parent.bottom
        anchors.bottomMargin: parent.height * 0.1
        
        font.family: 'FontAwesome'
        text: '\uf04c'
        
        color: theme.textColor
        font.pointSize: fontPointSize * 0.3
        
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
            if (active) {
                toggleRedshift()
            } else {
                stopRedshift()
            }
        }
    }
    
    Plasmoid.toolTipMainText: i18n('Redshift Control')
    Plasmoid.toolTipSubText: 'Use middle click and wheel to manage screen temperature'
    Plasmoid.icon: 'redshift'
    
}
