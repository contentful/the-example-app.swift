
import Foundation
import UIKit
import markymark
import ContentfulRichTextRenderer

class EmbeddedLessonSnippetsView: UIView,
                                  UIPickerViewDataSource,
                                  UIPickerViewDelegate,
                                  ResourceLinkBlockRepresentable{

    static let pickerOptions: [LessonSnippets.FieldKeys] = {
        return [
            LessonSnippets.FieldKeys.swift,
            LessonSnippets.FieldKeys.javaAndroid,
            LessonSnippets.FieldKeys.java,
            LessonSnippets.FieldKeys.javascript,
            LessonSnippets.FieldKeys.dotNet,
            LessonSnippets.FieldKeys.ruby,
            LessonSnippets.FieldKeys.python,
            LessonSnippets.FieldKeys.php,
            LessonSnippets.FieldKeys.curl
        ]
    }()

    var snippets: LessonSnippets?

    func configure(snippets: LessonSnippets) {
        self.snippets = snippets
        populateCodeSnippet(code: snippets.swift)
        programmingLanguageTextField.text = LessonSnippets.FieldKeys.swift.displayName() + " ▼" // Swift treats unicode characters as one character :-)
    }

    func populateCodeSnippet(code: String) {
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.black,
            .font: UIFont.sfMonoFont(ofSize: 10.0, weight: .regular)
        ]
        let attributedText = NSAttributedString(string: code, attributes: attributes)
        codeSnippetTextView.attributedText = attributedText
    }

    @objc func cancelPickingCodeLanguageAction(_ sender: UIBarButtonItem) {
        programmingLanguageTextField.endEditing(true)
    }

    @objc func donePickingCodeLanguageAction(_ sender: UIBarButtonItem) {
        if let picker = programmingLanguageTextField.inputView as? UIPickerView {
            let selectedRow = picker.selectedRow(inComponent: 0)
            let selectedLanguage = EmbeddedLessonSnippetsView.pickerOptions[selectedRow]
            programmingLanguageTextField.text = EmbeddedLessonSnippetsView.pickerOptions[selectedRow].displayName() + " ▼"
            programmingLanguageTextField.endEditing(true)
            
            guard let code = snippets?.valueForField(selectedLanguage) else { return }
            populateCodeSnippet(code: code)
        }
    }

    @IBOutlet weak var codeSnippetTextView: UITextView! {
        didSet {
            codeSnippetTextView.textContainerInset = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 0.0)
            codeSnippetTextView.backgroundColor = .lightGray
        }
    }

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

            let toolbar = UIToolbar()
            let cancelButton = UIBarButtonItem(title: NSLocalizedString("Cancel", comment: ""), style: .plain, target: self, action: #selector(EmbeddedLessonSnippetsView.cancelPickingCodeLanguageAction(_:)))
            let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            let doneButton = UIBarButtonItem(title: NSLocalizedString("Done", comment: ""), style: .done, target: self, action: #selector(EmbeddedLessonSnippetsView.donePickingCodeLanguageAction(_:)))
            toolbar.items = [cancelButton, flexibleSpace, doneButton]

            toolbar.sizeToFit()

            programmingLanguageTextField.inputAccessoryView = toolbar
        }
    }

    @IBOutlet weak var languageLabel: UILabel!

    // MARK: UIPickerViewDataSource

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return LessonSnippets.numberSupportedLanguages
    }


    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return EmbeddedLessonSnippetsView.pickerOptions[row].displayName()
    }

    // MARK: ResourceLinkBlockRepresentable

    var surroundingTextShouldWrap = false

    var context: [CodingUserInfoKey: Any] = [:]

    func layout(with width: CGFloat) {
        let size = sizeThatFits(CGSize(width: width, height: .greatestFiniteMagnitude))
        frame.size = size
        setNeedsLayout()
        layoutIfNeeded()
        let codeSnippetLabelSize = codeSnippetTextView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        codeSnippetTextView.frame.size.height = codeSnippetLabelSize.height
        self.frame.size.height = self.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
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
