/* GCompris - Users.qml
 *
 * Copyright (C) 2016 Johnny Jazeix <jazeix@gmail.com>
 *
 * Authors:
 *   Johnny Jazeix <jazeix@gmail.com>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License as published by
 *   the Free Software Foundation; either version 3 of the License, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details.
 *
 *   You should have received a copy of the GNU General Public License
 *   along with this program; if not, see <http://www.gnu.org/licenses/>.
 */
import QtQuick 2.1
import GCompris 1.0
import QtQuick.Controls 1.0

import "../../core"

ActivityBase {
    id: activity

    activityInfo: QtObject {
        property bool demo: false
    }

    pageComponent: Item {
        anchors.fill: parent
        GridView {
            id: users
            width: activity.width
            height: activity.height
            cellWidth: 210
            cellHeight: cellWidth
            model: MessageHandler.users
            highlight: Rectangle { color: "lightsteelblue"; radius: 5 }
            delegate: Rectangle {
                id: itemDelegate
                width: 200
                height: 200
                color: "red"
                property string name: modelData.name
                GCText {
                    text: modelData.name
                }

                MouseArea {
                    id: mouse
                    anchors.fill: parent
                    onClicked: { users.currentIndex = index ; print(modelData.name) } // todo what do we do? display list of action? (update user list, send configuration?)
                }
            }
        }

        Grid {
            rows: 2
            anchors.bottom: bar.top
            Button {
                id: createUserButton
                text: qsTr("Create an user")
                style: GCButtonStyle {}
                onClicked: {
                    createUserName.mode = "create";
                    createUserName.visible = true;
                    createUserName.defaultText = "";
                    createUserName.start();
                }
            }

            Button {
                id: updateUserButton
                text: qsTr("Update selected user")
                style: GCButtonStyle {}
                onClicked: {
                    if(users.currentItem) {
                        createUserName.mode = "update";
                        createUserName.visible = true;
                        createUserName.defaultText = users.currentItem.name;
                        createUserName.start();
                    }
                }
                enabled: users.currentItem && users.currentIndex != -1
            }

            Button {
                id: sendConfiguration
                text: qsTr("Delete selected user")
                style: GCButtonStyle {}
                onClicked: {
                    // Ask confirmation first
                    if(users.currentItem)
                        MessageHandler.deleteUser(users.currentItem.name);
                }
                enabled: users.currentItem && users.currentIndex != -1
            }

            Button {
                id: showResults
                text: qsTr("Display data")
                style: GCButtonStyle {}
                onClicked: {
                    // Ask confirmation first
                }
                enabled: users.currentItem && users.currentIndex != -1
            }
        }

        GCInputDialog {
            id: createUserName
            visible: false
            active: visible
            anchors.fill: parent
            z: 100
            property string mode: "create"

            message: mode == "create" ? qsTr("Name of the new user") : qsTr("Update user %1").arg(users.currentItem.name)
            onClose: createUserName.visible = false;

            button1Text: qsTr("OK")
            button2Text: qsTr("Cancel")
            onButton1Hit: {
                if(MessageHandler.groups.length !== 0) {
                    chooseLogin.visible = true;
                    chooseLogin.username = createUserName.inputtedText
                    chooseLogin.start();
                }
                else {
                    // no users, create the group directly
                    if(mode == "create") {
                        MessageHandler.createUser(createUserName.inputtedText, "")
                    }
                    else {
                        MessageHandler.updateUser(users.currentItem.name, createUserName.inputtedText, "")
                    }
                }
            }

            focus: true
            onStart: { inputItem.text = defaultText; inputItem.forceActiveFocus() }
            onStop: activity.forceActiveFocus()

            /**
             * type:string
             * inputted default text in the TextInput.
             */
            property string defaultText

            /**
             * type:string
             * inputted text in the TextInput.
             */
            property string inputtedText: inputItem ? inputItem.text : ""

            content: TextInput {
                id: textInput
                height: 60 * ApplicationInfo.ratio
                horizontalAlignment: TextInput.AlignHCenter
                verticalAlignment: TextInput.AlignVCenter
                text: createUserName.defaultText
                font.pointSize: 14
                font.weight: Font.DemiBold
            }
        }

        GCInputDialog {
            id: chooseLogin
            visible: false
            active: visible
            anchors.fill: parent

            message: qsTr("Add user to existing group")
            onClose: chooseLogin.visible = false;

            property string username

            button1Text: qsTr("OK")
            onButton1Hit: {
                createUserName.mode == "create" ?
                    MessageHandler.createUser(username, "", selectedGroups) :
                    MessageHandler.updateUser(users.currentItem.name, username, "", selectedGroups)
                chooseLogin.selectedGroups = [];
            }

            focus: true

            property string chosenLogin
            property var model: MessageHandler.groups

            property var selectedGroups: []
            content: ListView {
                id: view
                width: chooseLogin.width
                height: 100 * ApplicationInfo.ratio
                contentHeight: 60 * ApplicationInfo.ratio * model.count
                interactive: true
                clip: true
                model: chooseLogin.model
                delegate: GCDialogCheckBox {
                    id: userBox
                    text: modelData.name
                    // if you create a user, it's not in any group
                    // (need to handle case of existing name)
                    checked: createUserName.mode == "create" ? false :
                                       modelData.hasUser(users.currentItem.name)
                    onCheckedChanged: {
                        if(checked) {
                            chooseLogin.selectedGroups.push(modelData.name)
                            print("checked " + modelData.name)
                            print("checked " + chooseLogin.selectedGroups)
                        }
                        else {
                            chooseLogin.selectedGroups.splice(chooseLogin.selectedGroups.indexOf(modelData.name), 1)
                            print("not checked" + modelData.name)
                        }
                    }
                }
            }
        }

        Bar {
            id: bar
            content: BarEnumContent { value: home }
            onHomeClicked: activity.home()
        }
    }
}