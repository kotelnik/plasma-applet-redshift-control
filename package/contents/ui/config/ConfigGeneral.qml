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
import QtQuick.Controls 1.3
import QtQuick.Layouts 1.1

Item {

    property alias cfg_autostart: autostart.checked
    property alias cfg_smoothTransitions: smoothTransitions.checked
    property alias cfg_manualTemperatureStep: manualTemperatureStep.value
    property alias cfg_manualBrightnessStep: manualBrightnessStep.value
    property alias cfg_useDefaultIcons: useDefaultIcons.checked
    property string cfg_iconActive: plasmoid.configuration.iconActive
    property string cfg_iconInactive: plasmoid.configuration.iconInactive

    Label {
        text: i18n('Plasmoid version') + ': 1.0.18'
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

        Label {
            text: i18n("Manual brightness step:")
            Layout.alignment: Qt.AlignRight
        }
        SpinBox {
            id: manualBrightnessStep
            decimals: 2
            stepSize: 0.01
            minimumValue: 0.01
            maximumValue: 0.2
        }

        Item {
            width: 2
            height: 10
            Layout.columnSpan: 2
        }

        CheckBox {
            id: useDefaultIcons
            text: i18n('Use default icons')
            Layout.columnSpan: 2
        }

        Label {
            text: i18n("Active:")
            Layout.alignment: Qt.AlignRight
        }

        IconPicker {
            currentIcon: cfg_iconActive
            defaultIcon: 'redshift-status-on'
            onIconChanged: cfg_iconActive = iconName
            enabled: !useDefaultIcons.checked
        }

        Label {
            text: i18n("Inactive:")
            Layout.alignment: Qt.AlignRight
        }

        IconPicker {
            currentIcon: cfg_iconInactive
            defaultIcon: 'redshift-status-off'
            onIconChanged: cfg_iconInactive = iconName
            enabled: !useDefaultIcons.checked
        }
    }

}
