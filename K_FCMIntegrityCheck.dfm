inherited K_FormCMIntegrityCheck: TK_FormCMIntegrityCheck
  Left = 216
  Top = 319
  Width = 291
  Height = 302
  BorderIcons = [biSystemMenu, biMinimize]
  Caption = 'Media Objects Integrity Check'
  OldCreateOrder = True
  OnCloseQuery = FormCloseQuery
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  inherited BFMinBRPanel: TPanel
    Left = 273
    Top = 258
  end
  object LbEDLastDBMTS: TLabeledEdit
    Left = 139
    Top = 72
    Width = 134
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    EditLabel.Width = 126
    EditLabel.Height = 13
    EditLabel.Caption = 'Last maintenance date:     '
    EditLabel.Layout = tlCenter
    LabelPosition = lpLeft
    ReadOnly = True
    TabOrder = 1
  end
  object LbEDBMediaCount: TLabeledEdit
    Left = 139
    Top = 104
    Width = 134
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    EditLabel.Width = 128
    EditLabel.Height = 13
    EditLabel.Caption = 'Total media objects:           '
    EditLabel.Layout = tlCenter
    LabelPosition = lpLeft
    ReadOnly = True
    TabOrder = 2
  end
  object LbEDProcCount: TLabeledEdit
    Left = 139
    Top = 136
    Width = 134
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    EditLabel.Width = 127
    EditLabel.Height = 13
    EditLabel.Caption = 'Processed media objects:  '
    EditLabel.Layout = tlCenter
    LabelPosition = lpLeft
    ReadOnly = True
    TabOrder = 3
  end
  object LbEDErrCount: TLabeledEdit
    Left = 139
    Top = 168
    Width = 134
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    EditLabel.Width = 126
    EditLabel.Height = 13
    EditLabel.Caption = 'Errors:                                '
    EditLabel.Layout = tlCenter
    LabelPosition = lpLeft
    ReadOnly = True
    TabOrder = 4
  end
  object BtClose: TButton
    Left = 193
    Top = 229
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Exit'
    ModalResult = 2
    TabOrder = 5
  end
  object PBProgress: TProgressBar
    Left = 10
    Top = 201
    Width = 263
    Height = 17
    Anchors = [akLeft, akTop, akRight]
    Smooth = True
    TabOrder = 6
  end
  object BtStart: TButton
    Left = 105
    Top = 229
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Resume'
    TabOrder = 7
    OnClick = BtStartClick
  end
  object BtReport: TButton
    Left = 17
    Top = 229
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Report'
    TabOrder = 8
    OnClick = BtReportClick
  end
  object ChBOnlyUnrecovered: TCheckBox
    Left = 8
    Top = 8
    Width = 265
    Height = 17
    Caption = 'Process unrecovered objects only'
    TabOrder = 9
  end
  object ChBRestoreFromThumbnail: TCheckBox
    Left = 8
    Top = 40
    Width = 265
    Height = 17
    Caption = 'Restore bad images from DB thumbnails'
    TabOrder = 10
  end
end
