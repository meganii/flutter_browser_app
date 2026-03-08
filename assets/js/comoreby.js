(function (global) {
  function getTextInput() {
    return document.getElementById("text-input");
  }

  function copyCurrentTextInputValue() {
    var textInput = getTextInput();
    if (!textInput) {
      return;
    }

    var bridge = global.flutter_inappwebview;
    if (bridge && typeof bridge.callHandler === "function") {
      bridge.callHandler("handlerCopy", textInput.value);
    }
  }

  function dispatchEditorShortcut(options) {
    var textInput = getTextInput();
    if (!textInput) {
      return;
    }

    textInput.dispatchEvent(new KeyboardEvent("keydown", options));
    textInput.dispatchEvent(new KeyboardEvent("keyup", options));
  }

  global.comoreby = {
    cut: function () {
      copyCurrentTextInputValue();
      dispatchEditorShortcut({
        bubbles: true,
        cancelable: true,
        keyCode: 8
      });
    },
    indent: function () {
      dispatchEditorShortcut({
        bubbles: true,
        cancelable: true,
        keyCode: 39,
        ctrlKey: true
      });
    },
    outdent: function () {
      dispatchEditorShortcut({
        bubbles: true,
        cancelable: true,
        keyCode: 37,
        ctrlKey: true
      });
    },
    upLines: function () {
      dispatchEditorShortcut({
        bubbles: true,
        cancelable: true,
        keyCode: 38,
        ctrlKey: true
      });
    },
    downLines: function () {
      dispatchEditorShortcut({
        bubbles: true,
        cancelable: true,
        keyCode: 40,
        ctrlKey: true
      });
    },
    addIcon: function () {
      dispatchEditorShortcut({
        bubbles: true,
        cancelable: true,
        keyCode: 73,
        ctrlKey: true
      });
    },
    undo: function () {
      dispatchEditorShortcut({
        bubbles: true,
        cancelable: true,
        keyCode: 90,
        ctrlKey: true
      });
    },
    backspace: function () {
      dispatchEditorShortcut({
        bubbles: true,
        cancelable: true,
        keyCode: 8
      });
    }
  };
})(window);
