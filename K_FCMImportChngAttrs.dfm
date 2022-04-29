inherited K_FormCMImportChngAttrs: TK_FormCMImportChngAttrs
  Left = 383
  Top = 323
  BorderStyle = bsSingle
  Caption = 'Change Imported images attributes'
  ClientHeight = 201
  ClientWidth = 448
  OldCreateOrder = True
  OnCloseQuery = FormCloseQuery
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  inherited BFMinBRPanel: TPanel
    Left = 438
    Top = 191
    TabOrder = 9
  end
  object PBProgress: TProgressBar
    Left = 136
    Top = 173
    Width = 161
    Height = 17
    Anchors = [akLeft, akRight, akBottom]
    Smooth = True
    TabOrder = 0
  end
  object BtChange: TButton
    Left = 305
    Top = 170
    Width = 60
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = 'Change'
    Enabled = False
    TabOrder = 1
    OnClick = BtChangeClick
  end
  object LEdTotal: TLabeledEdit
    Left = 37
    Top = 44
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
    TabOrder = 2
    Text = '0000000'
  end
  object LEdProcessed: TLabeledEdit
    Left = 162
    Top = 44
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
    TabOrder = 3
    Text = '0000000'
  end
  object LEdImported: TLabeledEdit
    Left = 277
    Top = 44
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
    TabOrder = 4
  end
  object LEdErrors: TLabeledEdit
    Left = 379
    Top = 44
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
    TabOrder = 5
  end
  object LEdDate: TLabeledEdit
    Left = 95
    Top = 76
    Width = 96
    Height = 21
    Color = clBtnFace
    EditLabel.Width = 84
    EditLabel.Height = 13
    EditLabel.Caption = 'Last Import Date: '
    LabelPosition = lpLeft
    ReadOnly = True
    TabOrder = 6
  end
  object LEdTime: TLabeledEdit
    Left = 356
    Top = 76
    Width = 85
    Height = 21
    Color = clBtnFace
    EditLabel.Width = 84
    EditLabel.Height = 13
    EditLabel.Caption = 'Last Import Time: '
    LabelPosition = lpLeft
    ReadOnly = True
    TabOrder = 7
  end
  object BtExit: TButton
    Left = 379
    Top = 170
    Width = 60
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = 'Exit'
    ModalResult = 1
    TabOrder = 8
  end
  object LEdBri: TLabeledEdit
    Left = 67
    Top = 108
    Width = 50
    Height = 21
    Color = 10682367
    EditLabel.Width = 55
    EditLabel.Height = 13
    EditLabel.Caption = 'Brightness: '
    LabelPosition = lpLeft
    TabOrder = 10
  end
  object LEdCo: TLabeledEdit
    Left = 223
    Top = 108
    Width = 58
    Height = 21
    Color = 10682367
    EditLabel.Width = 45
    EditLabel.Height = 13
    EditLabel.Caption = 'Contrast: '
    LabelPosition = lpLeft
    TabOrder = 11
  end
  object LEdGam: TLabeledEdit
    Left = 381
    Top = 108
    Width = 58
    Height = 21
    Color = 10682367
    EditLabel.Width = 42
    EditLabel.Height = 13
    EditLabel.Caption = 'Gamma: '
    LabelPosition = lpLeft
    TabOrder = 12
  end
  object LEdFName: TLabeledEdit
    Left = 88
    Top = 10
    Width = 353
    Height = 21
    Color = clBtnFace
    EditLabel.Width = 77
    EditLabel.Height = 13
    EditLabel.Caption = 'Last Import File: '
    LabelPosition = lpLeft
    ReadOnly = True
    TabOrder = 13
  end
  object LEdConv: TLabeledEdit
    Left = 59
    Top = 171
    Width = 70
    Height = 21
    Anchors = [akLeft, akBottom]
    Color = clBtnFace
    EditLabel.Width = 49
    EditLabel.Height = 13
    EditLabel.Caption = 'Changed: '
    LabelPosition = lpLeft
    ReadOnly = True
    TabOrder = 14
  end
  object ChBRebuildThumbnails: TCheckBox
    Left = 8
    Top = 144
    Width = 433
    Height = 17
    Caption = 'Rebuild Image Thumbnails'
    TabOrder = 15
  end
end
