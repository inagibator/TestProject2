inherited K_FormCMImport: TK_FormCMImport
  Left = 441
  Top = 414
  BorderStyle = bsSingle
  Caption = 'Import after conversion'
  ClientHeight = 146
  ClientWidth = 448
  OldCreateOrder = True
  OnCloseQuery = FormCloseQuery
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  inherited BFMinBRPanel: TPanel
    Left = 438
    Top = 136
    TabOrder = 12
  end
  object PBProgress: TProgressBar
    Left = 11
    Top = 118
    Width = 145
    Height = 17
    Anchors = [akLeft, akRight, akBottom]
    Smooth = True
    TabOrder = 0
  end
  object BtReverse: TButton
    Left = 169
    Top = 115
    Width = 60
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = 'Reverse'
    TabOrder = 1
    OnClick = BtReverseClick
  end
  object BtProc: TButton
    Left = 309
    Top = 115
    Width = 60
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = 'Resume'
    TabOrder = 2
    OnClick = BtProcClick
  end
  inline FNameFrame: TN_FileNameFrame
    Tag = 161
    Left = 3
    Top = 8
    Width = 439
    Height = 27
    Anchors = [akLeft, akTop, akRight]
    PopupMenu = FNameFrame.FilePopupMenu
    TabOrder = 3
    inherited Label1: TLabel
      Width = 78
      Caption = 'XML File Name :'
    end
    inherited mbFileName: TComboBox
      Left = 96
      Width = 310
      Color = 10682367
      Text = '````'
    end
    inherited bnBrowse_1: TButton
      Left = 413
      Top = 2
    end
    inherited OpenDialog: TOpenDialog
      Filter = 'Media data files (*.xml)|slides*.xml|All files (*.*)|*.*'
      FilterIndex = 0
      Options = [ofEnableSizing]
    end
  end
  object LEdTotal: TLabeledEdit
    Left = 37
    Top = 48
    Width = 62
    Height = 24
    Color = clBtnFace
    EditLabel.Width = 27
    EditLabel.Height = 13
    EditLabel.Caption = 'Total:'
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Courier New'
    Font.Style = []
    LabelPosition = lpLeft
    ParentFont = False
    ReadOnly = True
    TabOrder = 4
    Text = '0000000'
  end
  object LEdProcessed: TLabeledEdit
    Left = 162
    Top = 48
    Width = 62
    Height = 24
    Color = clBtnFace
    EditLabel.Width = 53
    EditLabel.Height = 13
    EditLabel.Caption = 'Processed:'
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Courier New'
    Font.Style = []
    LabelPosition = lpLeft
    ParentFont = False
    ReadOnly = True
    TabOrder = 5
    Text = '0000000'
  end
  object LEdImported: TLabeledEdit
    Left = 277
    Top = 48
    Width = 62
    Height = 24
    Color = clBtnFace
    EditLabel.Width = 44
    EditLabel.Height = 13
    EditLabel.Caption = 'Imported:'
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Courier New'
    Font.Style = []
    LabelPosition = lpLeft
    ParentFont = False
    ReadOnly = True
    TabOrder = 6
  end
  object LEdErrors: TLabeledEdit
    Left = 379
    Top = 48
    Width = 62
    Height = 24
    Color = clBtnFace
    EditLabel.Width = 30
    EditLabel.Height = 13
    EditLabel.Caption = 'Errors:'
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Courier New'
    Font.Style = []
    LabelPosition = lpLeft
    ParentFont = False
    ReadOnly = True
    TabOrder = 7
  end
  object LEdDate: TLabeledEdit
    Left = 95
    Top = 80
    Width = 96
    Height = 21
    Color = clBtnFace
    EditLabel.Width = 84
    EditLabel.Height = 13
    EditLabel.Caption = 'Last Import Date: '
    LabelPosition = lpLeft
    ReadOnly = True
    TabOrder = 8
  end
  object LEdTime: TLabeledEdit
    Left = 354
    Top = 80
    Width = 85
    Height = 21
    Color = clBtnFace
    EditLabel.Width = 84
    EditLabel.Height = 13
    EditLabel.Caption = 'Last Import Time: '
    LabelPosition = lpLeft
    ReadOnly = True
    TabOrder = 9
  end
  object BtExit: TButton
    Left = 379
    Top = 115
    Width = 60
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = 'Exit'
    ModalResult = 1
    TabOrder = 10
  end
  object BtReImport: TButton
    Left = 239
    Top = 115
    Width = 60
    Height = 23
    Hint = 'Import objects not imported by errors'
    Anchors = [akRight, akBottom]
    Caption = 'ReImport'
    Enabled = False
    ParentShowHint = False
    ShowHint = True
    TabOrder = 11
    OnClick = BtReImportClick
  end
  object CloseTimer: TTimer
    Enabled = False
    Interval = 10
    OnTimer = CloseTimerTimer
    Left = 216
    Top = 80
  end
end
