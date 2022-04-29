object N_RichEditorForm: TN_RichEditorForm
  Left = 350
  Top = 446
  Width = 410
  Height = 344
  Caption = 'N_RichEditorForm'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 13
  object ActionMainMenuBar1: TActionMainMenuBar
    Left = 0
    Top = 0
    Width = 402
    Height = 23
    UseSystemFont = False
    ActionManager = ActionManager1
    Caption = 'ActionMainMenuBar1'
    ColorMap.HighlightColor = 15660791
    ColorMap.BtnSelectedColor = clBtnFace
    ColorMap.UnusedColor = 15660791
    EdgeOuter = esNone
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    Spacing = 0
  end
  object RichEdit: TRichEdit
    Left = 0
    Top = 23
    Width = 402
    Height = 268
    Align = alClient
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Courier New'
    Font.Style = []
    HideSelection = False
    MaxLength = 10000000
    ParentFont = False
    PlainText = True
    ScrollBars = ssBoth
    TabOrder = 1
    WordWrap = False
    OnKeyDown = RichEditKeyDown
    OnMouseDown = RichEditMouseDown
  end
  object StatusBar: TStatusBar
    Left = 0
    Top = 291
    Width = 402
    Height = 19
    Panels = <>
    SimplePanel = True
  end
  object ActionManager1: TActionManager
    ActionBars.SessionCount = 21
    ActionBars = <
      item
        Items.HideUnused = False
        Items = <
          item
            Items.HideUnused = False
            Items = <
              item
                Action = aFileNew
                ShortCut = 16462
              end
              item
                Action = aFileOpen
                ImageIndex = 8
                ShortCut = 16463
              end
              item
                Action = aFileSave
                Caption = '&Save'
                ShortCut = 16467
              end
              item
                Action = aFileSaveAs
                ImageIndex = 30
              end
              item
                Action = aFileAppend
                Caption = 'App&end...'
              end
              item
                Action = aFilePrintDlg
                ImageIndex = 14
                ShortCut = 16464
              end
              item
                Action = aFilePrintSetup
              end>
            Caption = '&File'
          end
          item
            Items.HideUnused = False
            Items = <
              item
                Action = EditCut1
                ImageIndex = 0
                ShortCut = 16472
              end
              item
                Action = EditCopy1
                ImageIndex = 1
                ShortCut = 16451
              end
              item
                Action = EditPaste1
                ImageIndex = 2
                ShortCut = 16470
              end
              item
                Action = EditSelectAll1
                ShortCut = 16449
              end
              item
                Action = EditUndo1
                ImageIndex = 3
                ShortCut = 16474
              end
              item
                Action = EditDelete1
                ImageIndex = 5
                ShortCut = 46
              end>
            Caption = '&Edit'
          end
          item
            Items.HideUnused = False
            Items = <
              item
                Action = SearchFind1
                ImageIndex = 34
                ShortCut = 16454
              end
              item
                Action = SearchFindNext1
                ImageIndex = 33
                ShortCut = 114
              end
              item
                Action = SearchReplace1
                ImageIndex = 32
              end
              item
                Action = SearchFindFirst1
              end>
            Caption = '&Search'
          end
          item
            Items.HideUnused = False
            Items = <
              item
                Action = RichEditBold1
                ImageIndex = 31
                ShortCut = 16450
              end
              item
                Action = RichEditItalic1
                ImageIndex = 29
                ShortCut = 16457
              end
              item
                Action = RichEditUnderline1
                ImageIndex = 28
                ShortCut = 16469
              end
              item
                Action = RichEditStrikeOut1
                ImageIndex = 44
              end
              item
                Action = RichEditBullets1
                Caption = 'Bull&ets'
                ImageIndex = 38
              end
              item
                Action = RichEditAlignLeft1
                ImageIndex = 35
              end
              item
                Action = RichEditAlignRight1
                ImageIndex = 36
              end
              item
                Action = RichEditAlignCenter1
                ImageIndex = 37
              end
              item
                Action = FontEdit1
              end>
            Caption = 'F&ormat'
          end
          item
            Items.HideUnused = False
            Items = <
              item
                Action = aOptionsWordWrap
                Caption = '&Word Wrap'
              end
              item
                Action = aOptionsPlainText
                Caption = '&Plain Text'
              end
              item
                Action = actDOS2WIN
                Caption = '&DOS To WIN'
                LastSession = 18
              end>
            Caption = 'O&ptions'
          end>
        ActionBar = ActionMainMenuBar1
        AutoSize = False
      end>
    Left = 240
    StyleName = 'XP Style'
    object aFileNew: TAction
      Category = 'File'
      Caption = '&New'
      ShortCut = 16462
      OnExecute = aFileNewExecute
    end
    object aFileOpen: TFileOpen
      Category = 'File'
      Caption = '&Open...'
      Hint = 'Open|Opens an existing file'
      ImageIndex = 8
      ShortCut = 16463
      OnAccept = aFileOpenAccept
    end
    object aFileSave: TAction
      Category = 'File'
      Caption = 'Save'
      ShortCut = 16467
      OnExecute = aFileSaveExecute
    end
    object aFileSaveAs: TFileSaveAs
      Category = 'File'
      Caption = 'Save &As...'
      Hint = 'Save As|Saves the active file with a new name'
      ImageIndex = 30
      BeforeExecute = aFileSaveAsBeforeExecute
      OnAccept = aFileSaveAsAccept
    end
    object aFileAppend: TAction
      Category = 'File'
      Caption = 'Append...'
      OnExecute = aFileAppendExecute
    end
    object aFilePrintDlg: TPrintDlg
      Category = 'File'
      Caption = '&Print...'
      ImageIndex = 14
      ShortCut = 16464
      OnAccept = aFilePrintDlgAccept
    end
    object aFilePrintSetup: TFilePrintSetup
      Category = 'File'
      Caption = 'Print Set&up...'
      Hint = 'Print Setup'
    end
    object EditCut1: TEditCut
      Category = 'Edit'
      Caption = 'Cu&t'
      Hint = 'Cut|Cuts the selection and puts it on the Clipboard'
      ImageIndex = 0
      ShortCut = 16472
    end
    object EditCopy1: TEditCopy
      Category = 'Edit'
      Caption = '&Copy'
      Hint = 'Copy|Copies the selection and puts it on the Clipboard'
      ImageIndex = 1
      ShortCut = 16451
    end
    object EditPaste1: TEditPaste
      Category = 'Edit'
      Caption = '&Paste'
      Hint = 'Paste|Inserts Clipboard contents'
      ImageIndex = 2
      ShortCut = 16470
    end
    object EditSelectAll1: TEditSelectAll
      Category = 'Edit'
      Caption = 'Select &All'
      Hint = 'Select All|Selects the entire document'
      ShortCut = 16449
    end
    object EditUndo1: TEditUndo
      Category = 'Edit'
      Caption = '&Undo'
      Hint = 'Undo|Reverts the last action'
      ImageIndex = 3
      ShortCut = 16474
    end
    object EditDelete1: TEditDelete
      Category = 'Edit'
      Caption = '&Delete'
      Hint = 'Delete|Erases the selection'
      ImageIndex = 5
      ShortCut = 46
    end
    object RichEditBold1: TRichEditBold
      Category = 'Format'
      AutoCheck = True
      Caption = '&Bold'
      Hint = 'Bold'
      ImageIndex = 31
      ShortCut = 16450
    end
    object RichEditItalic1: TRichEditItalic
      Category = 'Format'
      AutoCheck = True
      Caption = '&Italic'
      Hint = 'Italic'
      ImageIndex = 29
      ShortCut = 16457
    end
    object RichEditUnderline1: TRichEditUnderline
      Category = 'Format'
      AutoCheck = True
      Caption = '&Underline'
      Hint = 'Underline'
      ImageIndex = 28
      ShortCut = 16469
    end
    object RichEditStrikeOut1: TRichEditStrikeOut
      Category = 'Format'
      AutoCheck = True
      Caption = '&Strikeout'
      Hint = 'Strikeout'
      ImageIndex = 44
    end
    object RichEditBullets1: TRichEditBullets
      Category = 'Format'
      AutoCheck = True
      Caption = '&Bullets'
      Hint = 'Bullets|Inserts a bullet on the current line'
      ImageIndex = 38
    end
    object RichEditAlignLeft1: TRichEditAlignLeft
      Category = 'Format'
      AutoCheck = True
      Caption = 'Align &Left'
      Hint = 'Align Left|Aligns text at the left indent'
      ImageIndex = 35
    end
    object RichEditAlignRight1: TRichEditAlignRight
      Category = 'Format'
      AutoCheck = True
      Caption = 'Align &Right'
      Hint = 'Align Right|Aligns text at the right indent'
      ImageIndex = 36
    end
    object RichEditAlignCenter1: TRichEditAlignCenter
      Category = 'Format'
      AutoCheck = True
      Caption = '&Center'
      Hint = 'Center|Centers text between margins'
      ImageIndex = 37
    end
    object SearchFind1: TSearchFind
      Category = 'Search'
      Caption = '&Find...'
      Dialog.Options = [frDown, frFindNext]
      Hint = 'Find|Finds the specified text'
      ImageIndex = 34
      ShortCut = 16454
    end
    object SearchFindNext1: TSearchFindNext
      Category = 'Search'
      Caption = 'Find &Next'
      Enabled = False
      Hint = 'Find Next|Repeats the last find'
      ImageIndex = 33
      ShortCut = 114
    end
    object SearchReplace1: TSearchReplace
      Category = 'Search'
      Caption = '&Replace'
      Hint = 'Replace|Replaces specific text with different text'
      ImageIndex = 32
    end
    object SearchFindFirst1: TSearchFindFirst
      Category = 'Search'
      Caption = 'F&ind First'
      Hint = 'Find First|Finds the first occurance of specified text'
    end
    object FontEdit1: TFontEdit
      Category = 'Format'
      Caption = 'Select &Font...'
      Dialog.Font.Charset = DEFAULT_CHARSET
      Dialog.Font.Color = clWindowText
      Dialog.Font.Height = -11
      Dialog.Font.Name = 'MS Sans Serif'
      Dialog.Font.Style = []
      Hint = 'Font Select'
    end
    object aOptionsWordWrap: TAction
      Category = 'Options'
      Caption = 'Word Wrap'
      OnExecute = aOptionsWordWrapExecute
    end
    object aOptionsPlainText: TAction
      Category = 'Options'
      Caption = 'Plain Text'
      Checked = True
      OnExecute = aOptionsPlainTextExecute
    end
    object actDOS2WIN: TAction
      Category = 'Options'
      Caption = 'DOS To WIN'
      OnExecute = actDOS2WINExecute
    end
  end
end
