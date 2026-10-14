import QtQuick
import QtQml.Models

QtObject {
    id: observer

    property Item sceneRoot: null
    property var hiddenWidgets: []
    readonly property bool isSlot: sceneRoot !== null
        && "moduleName" in sceneRoot && "moduleSettings" in sceneRoot
        && "activeItem" in sceneRoot && "region" in sceneRoot

    // shortcut: Omarchy has no widget-visibility API; replace this scene-tree
    // adapter when the stock bar provides one. Never unload the widget.
    property Loader visibility: Loader {
        active: observer.isSlot
            && observer.hiddenWidgets.indexOf(String(observer.sceneRoot.moduleName)) !== -1
        sourceComponent: Item {
            id: overrides
            property bool applying: false
            Component.onCompleted: applying = true
            // Disable bindings before destruction so QML restores their originals.
            Component.onDestruction: applying = false
            Binding { target: observer.sceneRoot; property: "width"; value: 0; when: overrides.applying }
            Binding { target: observer.sceneRoot; property: "height"; value: 0; when: overrides.applying }
            Binding { target: observer.sceneRoot; property: "opacity"; value: 0; when: overrides.applying }
        }
    }

    // Observe containers until reaching a slot, including slots created later.
    property Instantiator branches: Instantiator {
        model: observer.sceneRoot && !observer.isSlot ? observer.sceneRoot.children : []
        delegate: Loader {
            id: branch
            required property var modelData
            source: Qt.resolvedUrl("BarVisibility.qml")
            onLoaded: {
                item.sceneRoot = Qt.binding(function() { return branch.modelData })
                item.hiddenWidgets = Qt.binding(function() { return observer.hiddenWidgets })
            }
        }
    }
}
