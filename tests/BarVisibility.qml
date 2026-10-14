import QtQuick
import Quickshell
import "." as Omaplug

ShellRoot {
    id: test
    property int step: 0
    property int loads: 0
    property var lateSlot: null

    function check(condition, message) {
        if (!condition) {
            console.error("FAIL", message)
            Qt.exit(1)
        }
    }

    Item {
        id: scene
        Row {
            id: row
            Item {
                id: slot
                property string moduleName: "test.popup"
                property var moduleSettings: ({})
                property string region: "right"
                property var activeItem: loader.item
                property int naturalWidth: 30
                width: naturalWidth
                height: 26
                Loader {
                    id: loader
                    active: true
                    sourceComponent: Item {
                        property bool opened: false
                        function open() { opened = true }
                        function close() { opened = false }
                        Component.onCompleted: test.loads++
                    }
                }
            }
            Item {
                id: naturalHidden
                property string moduleName: "test.natural"
                property var moduleSettings: ({})
                property string region: "right"
                property var activeItem: null
                property bool available: false
                visible: available
            }
            Item {
                id: ordinaryItem
                property string moduleName: "test.popup"
                width: 10
                height: 10
            }
        }
    }
    Omaplug.BarVisibility {
        id: adapter
        sceneRoot: scene
    }
    Component {
        id: lateComponent
        Item {
            property string moduleName: "test.late"
            property var moduleSettings: ({})
            property string region: "left"
            property var activeItem: null
        }
    }

    Timer {
        interval: 40
        running: true
        repeat: true
        onTriggered: {
            switch (test.step++) {
            case 0:
                test.check(slot.visible && test.loads === 1, "initial widget is loaded and visible")
                adapter.hiddenWidgets = ["test.popup", "test.natural", "test.late"]
                break
            case 1:
                test.check(slot.width === 0 && slot.height === 0 && slot.opacity === 0 && loader.active && loader.item !== null, "hidden widget stays loaded without occupying space")
                test.check(ordinaryItem.visible, "ordinary child with same module name is untouched")
                slot.activeItem.open()
                test.check(slot.activeItem.opened, "hidden widget popup can open")
                test.lateSlot = lateComponent.createObject(row)
                break
            case 2:
                test.check(test.lateSlot.opacity === 0, "newly created slots inherit hidden state")
                adapter.hiddenWidgets = []
                break
            case 3:
                test.check(slot.width === 30 && slot.height === 26 && slot.opacity === 1 && test.lateSlot.opacity === 1, "show restores dimensions and visibility")
                test.check(!naturalHidden.visible, "show preserves originally hidden widget")
                naturalHidden.available = true
                slot.naturalWidth = 42
                break
            case 4:
                test.check(naturalHidden.visible, "original visibility binding remains reactive")
                test.check(slot.width === 42, "original geometry binding remains reactive")
                test.check(test.loads === 1 && slot.activeItem.opened, "no widget or popup was rebuilt")
                adapter.hiddenWidgets = ["test.popup"]
                break
            case 5:
                adapter.sceneRoot = null
                break
            case 6:
                test.check(slot.width === 42 && slot.opacity === 1, "removing manager restores icons")
                console.log("bar-visibility-test: ok")
                Qt.quit()
            }
        }
    }
    Timer {
        interval: 2000
        running: true
        onTriggered: { console.error("FAIL test timed out"); Qt.exit(1) }
    }
}
