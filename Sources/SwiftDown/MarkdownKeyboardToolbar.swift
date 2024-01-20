//
//  MarkdownKeyboardToolbar.swift
//
//
//  Created by Ross Brandon on 18/01/24.
//

#if os(iOS)
import UIKit

/// Extends the SwiftDown UITextView to add a keyboard toolbar
/// Toolbar buttons insert common Markdown syntax:
/// - H1 heading text
/// - H2 heading text
/// - H3 heading text
/// - Bold text
/// - Italicized text
/// - Unordered lists
/// - Ordered lists
/// - Block quotes
/// - Links
/// - Code Blocks
extension SwiftDown {
  /// Adds a keyboard toolbar for quick markdown syntax
  /// Adds the selected markdown at the cursor's position
  func addKeyboardToolbar() {
    let toolbar = UIToolbar()
    toolbar.barStyle = UIBarStyle.default
    toolbar.isTranslucent = true
    let h1Button = getKeyboardTextButton(title: "H1", action: #selector(self.h1Action))
    let h2Button = getKeyboardTextButton(title: "H2", action: #selector(self.h2Action))
    let h3Button = getKeyboardTextButton(title: "H3", action: #selector(self.h3Action))
    let boldButton = getKeyboardImageButton(icon: "bold", action: #selector(self.boldAction))
    let italicizeButton = getKeyboardImageButton(icon: "italic", action: #selector(self.italicizeAction))
    let unorderedListButton = getKeyboardImageButton(
      icon: "list.bullet",
      action: #selector(self.unorderedListAction)
    )
    let orderedListButton = getKeyboardImageButton(
      icon: "list.number",
      action: #selector(self.orderedListAction)
    )
    let blockQuoteButton = getKeyboardImageButton(
      icon: "quote.closing",
      action: #selector(self.blockQuoteAction)
    )
    let linkButton = getKeyboardImageButton(icon: "link", action: #selector(self.linkAction))
    let codeBlockButton = getKeyboardImageButton(icon: "curlybraces", action: #selector(self.codeBlockAction))
    toolbar.setItems(
      [
        h1Button,
        h2Button,
        h3Button,
        boldButton,
        italicizeButton,
        unorderedListButton,
        orderedListButton,
        blockQuoteButton,
        linkButton,
        codeBlockButton
      ],
      animated: false
    )
    toolbar.isUserInteractionEnabled = true
    toolbar.sizeToFit()
    self.inputAccessoryView = toolbar
  }

  private func getKeyboardTextButton(title: String, action: Selector) -> UIBarButtonItem {
    return UIBarButtonItem(
      title: title,
      style: .plain,
      target: self,
      action: action
    )
  }

  private func getKeyboardImageButton(icon: String, action: Selector) -> UIBarButtonItem {
    return UIBarButtonItem(
      image: UIImage(systemName: icon),
      style: .plain,
      target: self,
      action: action
    )
  }

  /// Inserts the H1 `#` tag
  /// Adds 1 trailing whitespace at the current cursor position
  /// Moves the cursor position after the inserted characters
  @objc private func h1Action() {
    let selectedStart = self.selectedStart
    self.text.insert(contentsOf: "# ", at: self.text.index(self.text.startIndex, offsetBy: selectedStart))
    self.moveCursor(selectedStart + 2)
    self.highlighter?.applyStyles()
  }

  /// Inserts the H2 `##` tag
  /// Adds 1 trailing whitespace at the current cursor position
  /// Moves the cursor position after the inserted characters
  @objc private func h2Action() {
    let selectedStart = self.selectedStart
    self.text.insert(contentsOf: "## ", at: self.text.index(self.text.startIndex, offsetBy: selectedStart))
    self.moveCursor(selectedStart + 3)
    self.highlighter?.applyStyles()
  }

  /// Inserts the H3 `###` tag
  /// Adds 1 trailing whitespace at the current cursor position
  /// Moves the cursor position after the inserted characters
  @objc private func h3Action() {
    let selectedStart = self.selectedStart
    self.text.insert(contentsOf: "### ", at: self.text.index(self.text.startIndex, offsetBy: selectedStart))
    self.moveCursor(selectedStart + 4)
    self.highlighter?.applyStyles()
  }

  /// Inserts the bold`** **` tag
  /// If text is selected, surrounds the selected text with the bold tags
  /// Moves the cursor to the end of the selected text, if applicable
  @objc private func boldAction() {
    let selectedStart = self.selectedStart
    let selectedEnd = self.selectedEnd
    self.text.insert(contentsOf: "**", at: self.text.index(self.text.startIndex, offsetBy: selectedStart))
    self.text.insert(contentsOf: "**", at: self.text.index(self.text.startIndex, offsetBy: selectedEnd + 2))
    self.moveCursor(selectedEnd + 2)
    self.highlighter?.applyStyles()
  }

  /// Inserts the italic`* *` tag
  /// If text is selected, surrounds the selected text with the italic tags
  /// Moves the cursor to the end of the selected text, if applicable
  @objc private func italicizeAction() {
    let selectedStart = self.selectedStart
    let selectedEnd = self.selectedEnd
    self.text.insert(contentsOf: "*", at: self.text.index(self.text.startIndex, offsetBy: selectedStart))
    self.text.insert(contentsOf: "*", at: self.text.index(self.text.startIndex, offsetBy: selectedEnd + 1))
    self.moveCursor(selectedEnd + 1)
    self.highlighter?.applyStyles()
  }

  /// Inserts the unordered list`-` tag
  /// Adds 1 leading line break
  /// Adds 1 trailing whitespace at the current cursor position
  @objc private func unorderedListAction() {
    let selectedStart = self.selectedStart
    self.text.insert(contentsOf: "\n- ", at: self.text.index(self.text.startIndex, offsetBy: selectedStart))
    self.moveCursor(selectedStart + 3)
    self.highlighter?.applyStyles()
  }

  /// Inserts the ordered list`1.` tag
  /// Adds 1 leading line break
  /// Adds 1 trailing whitespace at the current cursor position1
  @objc private func orderedListAction() {
    let selectedStart = self.selectedStart
    self.text.insert(contentsOf: "\n1. ", at: self.text.index(self.text.startIndex, offsetBy: selectedStart))
    self.moveCursor(selectedStart + 3)
    self.highlighter?.applyStyles()
  }

  /// Inserts the block quote `>` tag
  /// Adds 1 trailing whitespace at the current cursor position
  @objc private func blockQuoteAction() {
    let selectedStart = self.selectedStart
    self.text.insert(contentsOf: "> ", at: self.text.index(self.text.startIndex, offsetBy: selectedStart))
    self.highlighter?.applyStyles()
  }

  /// Inserts the link`[]()` tag
  /// If text is selected, it is checked if it contains a link
  ///   If a link is detected, the selected text is placed inside the parenthesis
  ///   If a link is not detected, the selected text is placed inside the braces
  /// Moves the cursor into the text bracket or parenthesis as applicable
  @objc private func linkAction() {
    let selectedStart = self.selectedStart
    let selectedEnd = self.selectedEnd
    if self.containsLink() {
      self.text.insert(
        contentsOf: "[](",
        at: self.text.index(self.text.startIndex, offsetBy: selectedStart)
    )
      self.text.insert(
        contentsOf: ")",
        at: self.text.index(self.text.startIndex, offsetBy: selectedEnd + 3)
    )
      self.moveCursor(selectedStart + 1)
    } else {
      self.text.insert(
        contentsOf: "[",
        at: self.text.index(self.text.startIndex, offsetBy: selectedStart)
      )
      self.text.insert(
        contentsOf: "]()",
        at: self.text.index(self.text.startIndex, offsetBy: selectedEnd + 1)
      )
      self.moveCursor(selectedEnd + 3)
    }
    self.highlighter?.applyStyles()
  }

  /// Inserts the code block tag with line breaks
  /// If text is selected, moves the selected text inside the code block
  /// Adds line breaks to create the block
  /// Moves the cursor into the code block at the end of the selected text, if applicable
  @objc private func codeBlockAction() {
    let selectedStart = self.selectedStart
    let selectedEnd = self.selectedEnd
    self.text.insert(
      contentsOf: "```\n",
      at: self.text.index(self.text.startIndex,
      offsetBy: selectedStart)
    )
    self.text.insert(
      contentsOf: "\n```",
      at: self.text.index(self.text.startIndex, offsetBy: selectedEnd + 4)
    )
    self.moveCursor(selectedEnd + 4)
    self.highlighter?.applyStyles()
  }
}

/// Extends UITextView to provide cursor helper methods
extension UITextView {
  /// Get selected text range start position
  var selectedStart: Int {
    guard let selectedRange = self.selectedTextRange else {
      return 0
    }
    return self.offset(from: self.beginningOfDocument, to: selectedRange.start)
  }

  /// Get selected text range end position
  var selectedEnd: Int {
    guard let selectedRange = self.selectedTextRange else {
      return 0
    }
    return self.offset(from: self.beginningOfDocument, to: selectedRange.end)
  }

  /// Move cursor by the given offset
  func moveCursor(_ offset: Int = 1) {
    guard let newPosition = self.position(from: self.beginningOfDocument, offset: offset) else {
      return
    }
    self.selectedTextRange = self.textRange(from: newPosition, to: newPosition)
  }

  /// Validate if the selected text range contains a link
  func containsLink() -> Bool {
    guard let selectedTextRange = self.selectedTextRange,
      let selectedText = self.text(in: selectedTextRange) else {
      return false
    }
    do {
      let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
      let matches = detector.matches(
        in: selectedText, options: [],
        range: NSRange(location: 0, length: selectedText.utf16.count)
      )
      return !matches.isEmpty
    } catch {
      return false
    }
  }
}
#endif