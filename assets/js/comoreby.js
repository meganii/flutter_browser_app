(function (global) {
  var PASTE_PLUS_SELECTOR = "#editor .popup-menu .button-container .button";
  var PASTE_PLUS_TARGET_INDEX = 3;
  var PASTE_PLUS_TITLE = "Paste+";

  function getTextInput() {
    return document.getElementById("text-input");
  }

  function isCosenseDomain() {
    var host = global.location && global.location.hostname
      ? global.location.hostname
      : "";
    return host === "scrapbox.io" ||
      host.endsWith(".scrapbox.io") ||
      host === "cosense.com" ||
      host.endsWith(".cosense.com");
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

  async function readClipboardFromNative() {
    var bridge = global.flutter_inappwebview;
    if (!bridge || typeof bridge.callHandler !== "function") {
      throw new Error("Flutter bridge is unavailable");
    }

    var response = await bridge.callHandler("readClipboardText");
    if (!response || response.ok !== true) {
      throw new Error((response && response.error) || "Failed to read clipboard");
    }

    return response.text || "";
  }

  function insertAtCaret(text) {
    var textInput = getTextInput();
    if (!textInput || typeof textInput.value !== "string") {
      return false;
    }

    var start = typeof textInput.selectionStart === "number"
      ? textInput.selectionStart
      : textInput.value.length;
    var end = typeof textInput.selectionEnd === "number"
      ? textInput.selectionEnd
      : start;

    textInput.value = textInput.value.slice(0, start) + text + textInput.value.slice(end);

    var nextPos = start + text.length;
    if (typeof textInput.setSelectionRange === "function") {
      textInput.setSelectionRange(nextPos, nextPos);
    } else {
      textInput.selectionStart = nextPos;
      textInput.selectionEnd = nextPos;
    }

    textInput.dispatchEvent(new Event("input", { bubbles: true }));
    return true;
  }

  async function handlePastePlus(event) {
    event.preventDefault();
    event.stopPropagation();
    if (typeof event.stopImmediatePropagation === "function") {
      event.stopImmediatePropagation();
    }

    try {
      var text = await readClipboardFromNative();
      var inserted = insertAtCaret(text);
      if (!inserted) {
        global.alert("Paste+ failed: text-input not found");
      }
    } catch (error) {
      var message = error && error.message ? error.message : String(error);
      global.alert("Paste+ failed: " + message);
    }
  }

  function patchPastePlusButton() {
    if (!isCosenseDomain()) {
      return;
    }

    var target = '';
    var menu = [...document.querySelectorAll('#editor .popup-menu')]
      .find((el) => !el.classList.contains('suggest-popup-menu'));

    if (menu) {
      target = [...menu.querySelectorAll('.button-container .button')]
        .find((el) => el.textContent?.trim() === 'Paste');

      if (target) {
        target.textContent = 'Paste+';
      }
    }

    if (!(target instanceof HTMLElement)) {
      return;
    }
    if (target.dataset.pastePlusPatched === "1") {
      return;
    }

    var cloned = target.cloneNode(true);
    if (!(cloned instanceof HTMLElement)) {
      return;
    }

    cloned.dataset.pastePlusPatched = "1";
    cloned.innerText = PASTE_PLUS_TITLE;
    cloned.addEventListener("touchstart", handlePastePlus, {
      capture: true,
      passive: false
    });
    cloned.addEventListener("click", handlePastePlus, { capture: true });
    target.replaceWith(cloned);
  }

  function initPastePlus() {
    if (!isCosenseDomain()) {
      return;
    }
    if (global.__comorebyPastePlusInitialized) {
      return;
    }

    global.__comorebyPastePlusInitialized = true;

    var observer = new MutationObserver(function () {
      patchPastePlusButton();
    });
    observer.observe(document.body, {
      childList: true,
      subtree: true
    });

    patchPastePlusButton();
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", initPastePlus, { once: true });
  } else {
    initPastePlus();
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
