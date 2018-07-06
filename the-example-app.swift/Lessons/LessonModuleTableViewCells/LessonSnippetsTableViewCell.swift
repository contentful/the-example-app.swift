
import Foundation
import UIKit
import markymark

class LessonSnippetsTableViewCell: UITableViewCell, CellConfigurable, UIPickerViewDataSource, UIPickerViewDelegate {

    static let pickerOptions: [LessonSnippets.Fields] = {
        return [
            LessonSnippets.Fields.swift,
            LessonSnippets.Fields.javaAndroid,
            LessonSnippets.Fields.java,
            LessonSnippets.Fields.javascript,
            LessonSnippets.Fields.dotNet,
            LessonSnippets.Fields.ruby,
            LessonSnippets.Fields.python,
            LessonSnippets.Fields.php,
            LessonSnippets.Fields.curl
        ]
    }()

    var snippets: LessonSnippets?

    func configure(item: LessonSnippets) {
        self.snippets = item
        populateCodeSnippet(code: item.swift)
    }

    func resetAllContent() {
        snippets = nil
        codeSnippetLabel.text = ""
    }

    func populateCodeSnippet(code: String) {
        let snippet = """
        ```
        \(code)

        ```
        """
        let attributedText = Markdown.attributedText(text: snippet)
        codeSnippetLabel.attributedText = attributedText
    }

    @objc func cancelPickingCodeLanguageAction(_ sender: UIBarButtonItem) {
        programmingLanguageTextField.endEditing(true)
    }

    @objc func donePickingCodeLanguageAction(_ sender: UIBarButtonItem) {
        if let picker = programmingLanguageTextField.inputView as? UIPickerView {
            let selectedRow = picker.selectedRow(inComponent: 0)
            let selectedLanguage = LessonSnippetsTableViewCell.pickerOptions[selectedRow]
            programmingLanguageTextField.text = LessonSnippetsTableViewCell.pickerOptions[selectedRow].displayName()
            programmingLanguageTextField.endEditing(true)
            
            guard let code = snippets?.valueForField(selectedLanguage) else { return }
            populateCodeSnippet(code: code)
        }
    }

    @IBOutlet weak var codeSnippetLabel: UILabel!
    
    @IBOutlet weak var programmingLanguageTextField: UITextField! {
        didSet {
            programmingLanguageTextField.textColor = .blue
            programmingLanguageTextField.tintColor = .clear

            let pickerView = UIPickerView()

            pickerView.delegate = self
            pickerView.dataSource = self
            pickerView.showsSelectionIndicator = true
            pickerView.translatesAutoresizingMaskIntoConstraints = false
            programmingLanguageTextField.inputView = pickerView
            programmingLanguageTextField.borderStyle = .none

            // TODO: Localize.
            let toolbar = UIToolbar()
            let cancelButton = UIBarButtonItem(title: NSLocalizedString("Cancel", comment: ""), style: .plain, target: self, action: #selector(LessonSnippetsTableViewCell.cancelPickingCodeLanguageAction(_:)))
            let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            let doneButton = UIBarButtonItem(title: NSLocalizedString("Done", comment: ""), style: .done, target: self, action: #selector(LessonSnippetsTableViewCell.donePickingCodeLanguageAction(_:)))
            toolbar.items = [cancelButton, flexibleSpace, doneButton]

            toolbar.sizeToFit()

            programmingLanguageTextField.inputAccessoryView = toolbar
        }
    }

    @IBOutlet weak var languageLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    // MARK: UIPickerViewDataSource

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return LessonSnippets.numberSupportedLanguages
    }


    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return LessonSnippetsTableViewCell.pickerOptions[row].displayName()
    }
}

class CodingLanguageTextField: UITextField {

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if isFirstResponder {
            DispatchQueue.main.async {
                (sender as? UIMenuController)?.setMenuVisible(false, animated: false)
            }
            return false
        }

        return super.canPerformAction(action, withSender: sender)
    }

    override func addGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer) {
        if gestureRecognizer is UILongPressGestureRecognizer {
            gestureRecognizer.isEnabled = false
        }
        super.addGestureRecognizer(gestureRecognizer)
        return
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        textColor = .darkGray
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        textColor = .lightGray
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        textColor = .lightGray
    }
}
