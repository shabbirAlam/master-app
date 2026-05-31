import MarkdownUI
import SwiftUI

struct MarkdownTextView: View {
    let content: String
    let isUser: Bool

    var body: some View {
        if isUser {
            Markdown(content)
                .markdownTheme(userTheme)
                .textSelection(.enabled)
        } else {
            Markdown(content)
                .markdownTheme(assistantTheme)
                .textSelection(.enabled)
        }
    }

    private var userTheme: MarkdownUI.Theme {
        var t = MarkdownUI.Theme()
        t.text = ForegroundColor(.white) as TextStyle
        t = t.code {
            FontFamilyVariant(.monospaced)
            FontSize(.em(0.85))
            ForegroundColor(.white.opacity(0.9))
            BackgroundColor(.white.opacity(0.15))
        }
        t = t.link { ForegroundColor(Color(red: 0.55, green: 0.78, blue: 1.0)) }
        t = t.strong { FontWeight(.bold) }
        t = t.emphasis { FontStyle(.italic) }
        t = t.heading1 { config in
            config.label
                .markdownTextStyle { FontWeight(.bold); FontSize(.em(1.5)) }
                .markdownMargin(top: 8, bottom: 4)
        }
        t = t.heading2 { config in
            config.label
                .markdownTextStyle { FontWeight(.bold); FontSize(.em(1.3)) }
                .markdownMargin(top: 8, bottom: 4)
        }
        t = t.heading3 { config in
            config.label
                .markdownTextStyle { FontWeight(.semibold); FontSize(.em(1.1)) }
                .markdownMargin(top: 6, bottom: 3)
        }
        t = t.paragraph { config in
            config.label
                .relativeLineSpacing(.em(0.2))
                .markdownMargin(top: 2, bottom: 2)
        }
        t = t.codeBlock { config in
            config.label
                .padding(10)
                .background(Color.white.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .markdownMargin(top: 4, bottom: 4)
        }
        t = t.blockquote { config in
            config.label
                .padding(.leading, 10)
                .padding(.vertical, 2)
                .background(Color.white.opacity(0.06))
                .overlay(
                    Rectangle().fill(Color.white.opacity(0.3)).frame(width: 3),
                    alignment: .leading
                )
        }
        t = t.list { config in
            config.label.markdownMargin(top: 2, bottom: 2)
        }
        t = t.listItem { config in
            config.label.padding(.vertical, 1)
        }
        return t
    }

    private var assistantTheme: MarkdownUI.Theme {
        var t = MarkdownUI.Theme()
        t.text = ForegroundColor(.primary) as TextStyle
        t = t.code {
            FontFamilyVariant(.monospaced)
            FontSize(.em(0.85))
            ForegroundColor(.pink)
            BackgroundColor(.pink.opacity(0.06))
        }
        t = t.link { ForegroundColor(.blue) }
        t = t.strong { FontWeight(.bold) }
        t = t.emphasis { FontStyle(.italic) }
        t = t.heading1 { config in
            config.label
                .markdownTextStyle { FontWeight(.bold); FontSize(.em(1.5)) }
                .markdownMargin(top: 8, bottom: 4)
        }
        t = t.heading2 { config in
            config.label
                .markdownTextStyle { FontWeight(.bold); FontSize(.em(1.3)) }
                .markdownMargin(top: 8, bottom: 4)
        }
        t = t.heading3 { config in
            config.label
                .markdownTextStyle { FontWeight(.semibold); FontSize(.em(1.1)) }
                .markdownMargin(top: 6, bottom: 3)
        }
        t = t.paragraph { config in
            config.label
                .relativeLineSpacing(.em(0.2))
                .markdownMargin(top: 2, bottom: 2)
        }
        t = t.codeBlock { config in
            config.label
                .padding(10)
                .background(Color.gray.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .markdownMargin(top: 4, bottom: 4)
        }
        t = t.blockquote { config in
            config.label
                .padding(.leading, 10)
                .padding(.vertical, 2)
                .background(Color.gray.opacity(0.04))
                .overlay(
                    Rectangle().fill(Color.gray.opacity(0.3)).frame(width: 3),
                    alignment: .leading
                )
        }
        t = t.list { config in
            config.label.markdownMargin(top: 2, bottom: 2)
        }
        t = t.listItem { config in
            config.label.padding(.vertical, 1)
        }
        return t
    }
}
