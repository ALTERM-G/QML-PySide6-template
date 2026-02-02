import QtQuick
import QtQuick.Controls

Rectangle {
    id: dropzone
    width: 700
    height: 400
    radius: 16
    color: hovered ? Theme.hoverBackgroundColor : Theme.backgroundColor

    Canvas {
        id: border_canvas
        anchors.fill: parent
        onPaint: {
            var ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);
            ctx.lineWidth = 4;
            ctx.strokeStyle = dropzone.dragHovered ? Theme.themeColor : Theme.borderColor;
            ctx.setLineDash(dropzone.dragHovered ? [] : [6, 3]);
            ctx.lineJoin = "round";
            var r = dropzone.radius;
            var i = ctx.lineWidth / 2;
            var w = width - 2*i;
            var h = height - 2*i;

            ctx.beginPath();
            ctx.moveTo(i + r, i);
            ctx.lineTo(i + w - r, i);
            ctx.quadraticCurveTo(i + w, i, i + w, i + r);
            ctx.lineTo(i + w, i + h - r);
            ctx.quadraticCurveTo(i + w, i + h, i + w - r, i + h);
            ctx.lineTo(i + r, i + h);
            ctx.quadraticCurveTo(i, i + h, i, i + h - r);
            ctx.lineTo(i, i + r);
            ctx.quadraticCurveTo(i, i, i + r, i);
            ctx.closePath();
            ctx.stroke();
        }
    }

    signal fileDropped(string path, string type)
    signal dropped
    property bool hovered: false
    property string droppedFile: ""
    property string fileTypeLabel: ""
    property InfoPanel infoPanel
    property int filesCount: 0
    property bool multiFile: false
    property var droppedFiles: []
    property string errorMessage: ""
    property string successMessage: ""
    property bool dragHovered: false

    HoverHandler {
        acceptedDevices: PointerDevice.Mouse
        onHoveredChanged: dropzone.hovered = hovered
    }

    Text {
        id: mainText
        anchors.top: parent.top
        anchors.topMargin: 30
        anchors.centerIn: parent
        visible: dropzone.droppedFile === ""
        font.family: "Terminus"
        font.pixelSize: Typography.bigFontSize
        color: Theme.textColor
        wrapMode: Text.NoWrap
        elide: Text.ElideNone
        verticalAlignment: Text.AlignTop
        text:
            "██████╗ ██████╗  ██████╗ ██████╗     ███████╗██╗██╗     ███████╗\n" +
            "██╔══██╗██╔══██╗██╔═══██╗██╔══██╗    ██╔════╝██║██║     ██╔════╝\n" +
            "██║  ██║██████╔╝██║   ██║██████╔╝    █████╗  ██║██║     █████╗  \n" +
            "██║  ██║██╔══██╗██║   ██║██╔═══╝     ██╔══╝  ██║██║     ██╔══╝  \n" +
            "██████╔╝██║  ██║╚██████╔╝██║         ██║     ██║███████╗███████╗\n" +
            "╚═════╝ ╚═╝  ╚═╝ ╚═════╝ ╚═╝         ╚═╝     ╚═╝╚══════╝╚══════╝"
    }

    Column {
        anchors.top: parent.top
        anchors.topMargin: 40
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 10
        visible: dropzone.droppedFile !== ""

        Image {
            id: fileIcon
            source: "../../assets/icons/file.svg"
            width: 60
            height: 60
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Text {
            id: filePathText
            anchors.horizontalCenter: parent.horizontalCenter
            width: dropzone.width - 40
            font.family: Typography.fontBold
            font.pixelSize: Typography.iconFontSize
            color: Theme.textColor
            wrapMode: Text.Wrap
            horizontalAlignment: Text.AlignHCenter
            text: dropzone.droppedFile
            visible: dropzone.errorMessage === ""
        }

        Text {
            id: errorText
            anchors.horizontalCenter: parent.horizontalCenter
            width: dropzone.width - 40
            color: Theme.themeColor
            font.family: Typography.fontBold
            font.pixelSize: Typography.bigFontSize
            visible: dropzone.errorMessage !== ""
            text: dropzone.errorMessage
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
        }

        Text {
            id: successText
            anchors.horizontalCenter: parent.horizontalCenter
            width: dropzone.width - 40
            color: Theme.successTextColor
            font.family: Typography.fontBold
            font.pixelSize: Typography.bigFontSize
            visible: dropzone.successMessage !== ""
            text: dropzone.successMessage
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
        }
    }

    DropArea {
        anchors.fill: parent

        onEntered: function(drag) {
            if (drag.hasUrls) {
                dropzone.dragHovered = true
                border_canvas.requestPaint()
            }
        }

        onExited: {
            dropzone.dragHovered = false
            border_canvas.requestPaint()
        }

        onDropped: drop => {
            dropzone.dragHovered = false
            dropzone.hovered = false
            dropzone.errorMessage = ""
            dropzone.successMessage = ""
            border_canvas.requestPaint()
            if (!drop.hasUrls) return;

            if (!dropzone.multiFile) {
                var urlString = drop.urls[0].toString();
                var localPath = urlString.startsWith("file:///") ? urlString.substring(7)
                              : urlString.startsWith("file://") ? urlString.substring(6)
                              : urlString;

                var info = fileHelper.getInfo(localPath);
                if (info.isDir) return;

                dropzone.droppedFile = localPath;
                dropzone.droppedFiles = [localPath];
                var fileType = Data.extensionToTypeMap[info.extension] ?? "Unknown";
                dropzone.fileTypeLabel = fileType + (info.extension ? " (." + info.extension + ")" : "");
                dropzone.fileDropped(info.path, fileType);

                if (dropzone.infoPanel) {
                    dropzone.infoPanel.filePath = info.path;
                    dropzone.infoPanel.fileName = info.name;
                    dropzone.infoPanel.fileType = fileType;
                    dropzone.infoPanel.fileExtension = info.extension;
                    dropzone.infoPanel.fileSize = info.size;
                    dropzone.infoPanel.lastModified = info.lastModified;
                }

            } else {
                var files = []
                var count = 0;

                for (var i = 0; i < drop.urls.length; i++) {
                    var urlString = drop.urls[i].toString()
                    var localPath = urlString.startsWith("file:///") ? urlString.substring(7)
                                  : urlString.startsWith("file://") ? urlString.substring(6)
                                  : urlString

                    var info = fileHelper.getInfo(localPath)
                    if (info.isDir) continue

                    files.push(localPath)

                    var fileType = Data.extensionToTypeMap[info.extension] ?? "Unknown"
                    dropzone.fileDropped(localPath, fileType)
                    count++
                }

                dropzone.droppedFiles = files
                dropzone.filesCount = count

                if (count > 0) {
                    dropzone.droppedFile = count + " files selected"
                }
            }
        }
    }

    function showError(msg) {
        errorMessage = msg
        successMessage = ""
        border_canvas.requestPaint()
    }

    function showSuccess(msg) {
        successMessage = msg
        errorMessage = ""
    }
}
