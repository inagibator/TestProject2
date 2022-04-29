object N_MetafEdForm: TN_MetafEdForm
  Left = 278
  Top = 243
  Width = 356
  Height = 256
  Caption = 'View, Edit Print Metafile'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 13
  object PageControl: TPageControl
    Left = 0
    Top = 29
    Width = 348
    Height = 150
    ActivePage = tsAttribs
    Align = alClient
    TabOrder = 0
    object tsAttribs: TTabSheet
      Caption = 'Attribs'
      inline frFileName: TN_FileNameFrame
        Tag = 161
        Left = 0
        Top = 0
        Width = 340
        Height = 32
        PopupMenu = frFileName.FilePopupMenu
        TabOrder = 0
        inherited Label1: TLabel
          Left = 1
          Width = 22
          Caption = 'File :'
        end
        inherited mbFileName: TComboBox
          Left = 28
          Width = 282
        end
        inherited bnBrowse_1: TButton
          Left = 313
        end
      end
      object edSizeInPix: TLabeledEdit
        Left = 64
        Top = 31
        Width = 89
        Height = 21
        EditLabel.Width = 54
        EditLabel.Height = 13
        EditLabel.Caption = 'Size in Pix :'
        LabelPosition = lpLeft
        TabOrder = 1
      end
      object edSizeInKb: TLabeledEdit
        Left = 65
        Top = 59
        Width = 43
        Height = 21
        EditLabel.Width = 53
        EditLabel.Height = 13
        EditLabel.Caption = 'Size in Kb :'
        LabelPosition = lpLeft
        TabOrder = 2
      end
      object edNRecords: TLabeledEdit
        Left = 177
        Top = 59
        Width = 44
        Height = 21
        EditLabel.Width = 54
        EditLabel.Height = 13
        EditLabel.Caption = 'NRecords :'
        LabelPosition = lpLeft
        TabOrder = 3
      end
    end
    object TabSheet2: TTabSheet
      Caption = 'TabSheet2'
      ImageIndex = 1
    end
  end
  object StatusBar: TStatusBar
    Left = 0
    Top = 179
    Width = 348
    Height = 19
    Panels = <>
    SimplePanel = True
  end
  object ToolBar1: TToolBar
    Left = 0
    Top = 0
    Width = 348
    Height = 29
    ButtonHeight = 24
    ButtonWidth = 25
    Caption = 'ToolBar1'
    Images = N_ButtonsForm.ButtonsList
    TabOrder = 2
    object ToolButton1: TToolButton
      Left = 0
      Top = 2
      Action = actFileLoad
      ParentShowHint = False
      ShowHint = True
    end
    object ToolButton5: TToolButton
      Left = 25
      Top = 2
      Action = actFileSave
    end
    object ToolButton2: TToolButton
      Left = 50
      Top = 2
      Action = actEditCopy
      ParentShowHint = False
      ShowHint = True
    end
    object ToolButton3: TToolButton
      Left = 75
      Top = 2
      Action = actEditPaste
      ParentShowHint = False
      ShowHint = True
    end
    object ToolButton4: TToolButton
      Left = 100
      Top = 2
      Action = actViewMetafile
      ParentShowHint = False
      ShowHint = True
    end
  end
  object MainMenu1: TMainMenu
    Images = N_ButtonsForm.ButtonsList
    Left = 280
    object File1: TMenuItem
      Caption = 'File'
      object LoadMetafile1: TMenuItem
        Action = actFileLoad
      end
      object SaveMetafile1: TMenuItem
        Action = actFileSave
      end
    end
    object Edit1: TMenuItem
      Caption = 'Edit'
      object CopyToClipboard1: TMenuItem
        Action = actEditCopy
      end
      object PastefromClipboard1: TMenuItem
        Action = actEditPaste
      end
    end
    object View1: TMenuItem
      Caption = 'View'
      object ViewMetafile1: TMenuItem
        Action = actViewMetafile
      end
      object ViewXMLfile1: TMenuItem
        Action = actViewXML
      end
    end
    object Import1: TMenuItem
      Caption = 'Import'
      object ImportfromXMLlinesfiles1: TMenuItem
        Action = actImpXMLLines
      end
    end
    object Export1: TMenuItem
      Caption = 'Export'
      Hint = 'Export current metafile to XML file as lines'
      object ExporttoSDMLines1: TMenuItem
        Action = actExpXMLLines
      end
      object ExportToText1: TMenuItem
        Action = actExpTxtDump
      end
    end
    object Debug1: TMenuItem
      Caption = 'Debug'
      object CreateATest1emf1: TMenuItem
        Action = aDebCreateATest1EMF
      end
      object CreateATest2emf1: TMenuItem
        Action = aDebCreateATest2EMF
      end
    end
  end
  object ActionList1: TActionList
    Images = N_ButtonsForm.ButtonsList
    Left = 312
    object actFileLoad: TAction
      Category = 'File'
      Caption = 'Load Metafile'
      Hint = 'Load  Metafile from *.emf file'
      ImageIndex = 1
      OnExecute = actFileLoadExecute
    end
    object actEditCopy: TAction
      Category = 'Edit'
      Caption = 'Copy to Clipboard'
      Hint = 'Copy Metafile to Clipboard'
      ImageIndex = 12
      OnExecute = actEditCopyExecute
    end
    object actEditPaste: TAction
      Category = 'Edit'
      Caption = 'Paste from Clipboard'
      Hint = 'Paste Metafile from Clipboard'
      ImageIndex = 13
      OnExecute = actEditPasteExecute
    end
    object actViewMetafile: TAction
      Category = 'View'
      Caption = 'View Metafile'
      Hint = 'View current Metafile'
      ImageIndex = 11
      OnExecute = actViewMetafileExecute
    end
    object actFileSave: TAction
      Category = 'File'
      Caption = 'Save Metafile'
      ImageIndex = 2
      OnExecute = actFileSaveExecute
    end
    object actExpXMLLines: TAction
      Category = 'Export'
      Caption = 'Export to XML Lines'
      Hint = 'Export current metafile to XML file as lines'
      OnExecute = actExpXMLLinesExecute
    end
    object actViewXML: TAction
      Category = 'View'
      Caption = 'View XML file'
      Hint = 'View XML file'
      ImageIndex = 20
      OnExecute = actViewXMLExecute
    end
    object actImpXMLLines: TAction
      Category = 'Import'
      Caption = 'Import from XML lines files'
      Hint = 'Import from XML lines files'
      OnExecute = actImpXMLLinesExecute
    end
    object actExpTxtDump: TAction
      Category = 'Export'
      Caption = 'Export To Text Dump'
      ImageIndex = 5
      OnExecute = actExpTxtDumpExecute
    end
    object aDebCreateATest1EMF: TAction
      Caption = 'Create ATest1.emf '
      OnExecute = aDebCreateATest1EMFExecute
    end
    object aDebCreateATest2EMF: TAction
      Caption = 'Create ATest2.emf '
      OnExecute = aDebCreateATest2EMFExecute
    end
  end
end
